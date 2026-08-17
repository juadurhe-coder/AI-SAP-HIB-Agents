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

const CUTOFF_DATE = new Date('2020-01-01T00:00:00Z');

// DRY helper: encapsulates hostname + headers for all GitHub API calls
function ghApi(apiPath, method = 'GET', body = null) {
  return request({
    hostname: 'api.github.com',
    path: apiPath,
    method,
    headers: HEADERS
  }, body);
}

function shouldIgnore(filePath) {
  const norm = filePath.replace(/\\/g, '/').toLowerCase();
  return norm.includes('/.git/') || 
         norm.includes('/node_modules/') || 
         norm.includes('/.gemini/') || 
         norm.includes('/.system_generated/') || 
         norm.includes('/test_office_automation/') || 
         norm.includes('/browser_recordings/') || 
         norm.includes('/dist/') || 
         norm.includes('/build/');
}

function getWorkspaceFiles(dir, includeProjects = true, fileList = []) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (shouldIgnore(fullPath)) continue;

    const relPath = path.relative(WORKSPACE_DIR, fullPath).replace(/\\/g, '/');
    if (!includeProjects && relPath.startsWith('Projects/')) {
      continue; // Excluir Projects/ para el repositorio de equipo
    }

    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      getWorkspaceFiles(fullPath, includeProjects, fileList);
    } else {
      if (stat.mtime > CUTOFF_DATE) {
        fileList.push({
          fullPath,
          relativePath: relPath,
          size: stat.size
        });
      }
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
  }

  const newTreeData = await ghApi(`/repos/${OWNER}/${repoName}/git/trees`, 'POST', {
    base_tree: parentTreeSha,
    tree: treeEntries
  });

  const newCommitData = await ghApi(`/repos/${OWNER}/${repoName}/git/commits`, 'POST', {
    message: commitMessage,
    tree: newTreeData.sha,
    parents: [latestCommitSha]
  });

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
