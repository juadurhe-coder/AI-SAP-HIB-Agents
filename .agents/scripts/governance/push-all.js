const fs = require('fs');
const path = require('path');
const https = require('https');

// Configuration
const OWNER = 'juadurhe-coder';
const TEAM_REPO = 'AI-SAP-HIB-Agents';
const PRIVATE_REPO = 'AI-HIBERUS-Projects';
const BRANCH = 'main';
const WORKSPACE_DIR = path.resolve(__dirname, '../../..');
const CONFIG_PATH = path.join(process.env.USERPROFILE || process.env.HOME, '.gemini', 'antigravity-ide', 'mcp_config.json');

// Helper to make HTTPS requests
function request(options, body = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            resolve(data);
          }
        } else {
          const err = new Error(`Request failed with status ${res.statusCode}: ${data}`);
          err.statusCode = res.statusCode;
          err.responseData = data;
          reject(err);
        }
      });
    });
    req.on('error', (err) => reject(err));
    if (body) {
      req.write(typeof body === 'string' ? body : JSON.stringify(body));
    }
    req.end();
  });
}

// Retrieve token from mcp_config.json
function getGithubToken() {
  try {
    const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
    const token = config?.mcpServers?.['github-mcp-server']?.env?.GITHUB_PERSONAL_ACCESS_TOKEN;
    if (!token) throw new Error('Token not found in mcp_config.json');
    return token;
  } catch (err) {
    console.error('Error reading token:', err.message);
    process.exit(1);
  }
}

const TOKEN = getGithubToken();

const HEADERS = {
  'User-Agent': 'Antigravity-Push-Script',
  'Authorization': `token ${TOKEN}`,
  'Content-Type': 'application/json',
  'Accept': 'application/vnd.github.v3+json'
};

const IGNORED_DIRS = new Set([
  'node_modules',
  '.git',
  '.gemini',
  '.system_generated',
  'test_office_automation',
  'browser_recordings',
  'dist',
  'build',
  '.idea',
  '.vscode'
]);

const IGNORED_EXTS = new Set([
  '.mp4',
  '.mov',
  '.avi',
  '.zip',
  '.tar',
  '.gz',
  '.exe'
]);

const MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024; // 25 MB max per file for Git blobs

// DRY helper: encapsulates hostname + headers with automatic retry on transient errors (500, 502, 503, 504)
async function ghApi(apiPath, method = 'GET', body = null, retries = 3) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      return await request({
        hostname: 'api.github.com',
        path: apiPath,
        method,
        headers: HEADERS
      }, body);
    } catch (err) {
      const isTransient = err.statusCode >= 500 && err.statusCode < 600;
      if (isTransient && attempt < retries) {
        const delayMs = attempt * 2000;
        console.log(`   ⏳ Reintentando ${method} ${apiPath} (intento ${attempt + 1}/${retries}) tras ${delayMs}ms...`);
        await new Promise(r => setTimeout(r, delayMs));
      } else {
        throw err;
      }
    }
  }
}

function shouldIgnore(fileName, stat) {
  const lower = fileName.toLowerCase();
  if (stat.isDirectory()) {
    return IGNORED_DIRS.has(lower);
  }
  const ext = path.extname(lower);
  if (IGNORED_EXTS.has(ext)) {
    return true;
  }
  if (stat.size > MAX_FILE_SIZE_BYTES) {
    console.log(`   ⚠️ Ignorando archivo superior a 25MB: ${fileName} (${Math.round(stat.size / 1024 / 1024)} MB)`);
    return true;
  }
  return false;
}

function getWorkspaceFiles(dir, includeProjects = true, fileList = []) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (shouldIgnore(file, stat)) continue;

    const relPath = path.relative(WORKSPACE_DIR, fullPath).replace(/\\/g, '/');
    if (!includeProjects && relPath.startsWith('Projects/')) {
      continue; // Excluir Projects/ para el repositorio de equipo
    }

    if (stat.isDirectory()) {
      getWorkspaceFiles(fullPath, includeProjects, fileList);
    } else {
      fileList.push({
        fullPath,
        relativePath: relPath,
        size: stat.size
      });
    }
  }
  return fileList;
}

async function ensureRepo(repoName, description) {
  console.log(`\n🔎 Comprobando repositorio '${OWNER}/${repoName}' en GitHub...`);
  try {
    await ghApi(`/repos/${OWNER}/${repoName}`);
    console.log(`✅ El repositorio '${OWNER}/${repoName}' existe.`);
  } catch (err) {
    if (err.statusCode === 404) {
      console.log(`⚡ Creando repositorio '${OWNER}/${repoName}' automáticamente...`);
      await ghApi('/user/repos', 'POST', {
        name: repoName,
        description: description,
        private: false,
        auto_init: true
      });
      console.log(`🎉 Repositorio '${OWNER}/${repoName}' creado exitosamente.`);
      await new Promise(r => setTimeout(r, 3000));
    } else {
      throw err;
    }
  }
}

async function pushToRepo(repoName, files, commitMessage) {
  console.log(`\n🚀 Publicando ${files.length} archivos en '${OWNER}/${repoName}'...`);
  
  let refData;
  try {
    refData = await ghApi(`/repos/${OWNER}/${repoName}/git/refs/heads/${BRANCH}`);
  } catch (err) {
    if (err.statusCode === 404) {
      const repoInfo = await ghApi(`/repos/${OWNER}/${repoName}`);
      const defBranch = repoInfo.default_branch || 'main';
      refData = await ghApi(`/repos/${OWNER}/${repoName}/git/refs/heads/${defBranch}`);
    } else {
      throw err;
    }
  }

  const latestCommitSha = refData.object.sha;
  const commitData = await ghApi(`/repos/${OWNER}/${repoName}/git/commits/${latestCommitSha}`);
  const parentTreeSha = commitData.tree.sha;

  const treeEntries = [];
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const fileBuffer = fs.readFileSync(file.fullPath);
    const base64Content = fileBuffer.toString('base64');

    const blobData = await ghApi(`/repos/${OWNER}/${repoName}/git/blobs`, 'POST', {
      content: base64Content,
      encoding: 'base64'
    });

    treeEntries.push({
      path: file.relativePath,
      mode: '100644',
      type: 'blob',
      sha: blobData.sha
    });

    if ((i + 1) % 50 === 0 || i === files.length - 1) {
      console.log(`   📤 Subidos ${i + 1}/${files.length} blobs...`);
    }
  }

  console.log(`   🌳 Creando árbol de Git de forma incremental...`);
  const BATCH_SIZE = 80;
  let currentBaseTreeSha = parentTreeSha;

  for (let b = 0; b < treeEntries.length; b += BATCH_SIZE) {
    const chunk = treeEntries.slice(b, b + BATCH_SIZE);
    const chunkTreeData = await ghApi(`/repos/${OWNER}/${repoName}/git/trees`, 'POST', {
      base_tree: currentBaseTreeSha,
      tree: chunk
    });
    currentBaseTreeSha = chunkTreeData.sha;
    console.log(`   🌳 Árbol incremental actualizado (${Math.min(b + BATCH_SIZE, treeEntries.length)}/${treeEntries.length} entradas)...`);
  }

  console.log(`   📝 Creando Commit...`);
  const newCommitData = await ghApi(`/repos/${OWNER}/${repoName}/git/commits`, 'POST', {
    message: commitMessage,
    tree: currentBaseTreeSha,
    parents: [latestCommitSha]
  });

  console.log(`   📌 Actualizando rama '${BRANCH}'...`);
  await ghApi(`/repos/${OWNER}/${repoName}/git/refs/heads/${BRANCH}`, 'PATCH', {
    sha: newCommitData.sha,
    force: true
  });

  console.log(`✅ Repositorio '${OWNER}/${repoName}' actualizado correctamente.`);
}

async function run() {
  console.log('🔍 Escaneando archivos locales...');

  // 1. Repositorio de Equipo (Solo agentes, sin Projects/)
  const teamFiles = getWorkspaceFiles(WORKSPACE_DIR, false);
  console.log(`📦 Archivos para el Repositorio de Equipo ('${TEAM_REPO}'): ${teamFiles.length}`);

  // 2. Repositorio Privado (Completo: .agents/ + Projects/)
  const privateFiles = getWorkspaceFiles(WORKSPACE_DIR, true);
  console.log(`🔒 Archivos para el Repositorio Privado ('${PRIVATE_REPO}'): ${privateFiles.length}`);

  try {
    // Publicar en el Repositorio de Equipo
    await ensureRepo(TEAM_REPO, 'Suite de Agentes, Reglas, Workflows y Estándares de HIBERUS (Read-Only para Equipo)');
    await pushToRepo(TEAM_REPO, teamFiles, 'Update team framework: .agents profiles and onboarding assets');

    // Publicar en el Repositorio Privado Personal
    await ensureRepo(PRIVATE_REPO, 'Respaldo Privado Completo de Proyectos SAP y Agentes HIBERUS');
    await pushToRepo(PRIVATE_REPO, privateFiles, 'Update private full workspace: .agents and Projects');

    console.log('\n🎉 ¡PROCESO FINALIZADO CON ÉXITO!');
    console.log(`- Repo Equipo (Limpio sin Projects): https://github.com/${OWNER}/${TEAM_REPO}`);
    console.log(`- Repo Privado Personal: https://github.com/${OWNER}/${PRIVATE_REPO}`);
  } catch (err) {
    console.error('\n❌ Error durante la publicación:', err.message);
  }
}

run();
