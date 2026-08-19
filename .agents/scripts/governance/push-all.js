const fs = require('fs');
const path = require('path');
const https = require('https');
const crypto = require('crypto');

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

// Compute Git Blob SHA-1 (identically to native git)
function computeGitBlobSha(buffer) {
  const header = `blob ${buffer.length}\0`;
  return crypto.createHash('sha1').update(header).update(buffer).digest('hex');
}

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

// Secret Scanner: Checks for hardcoded tokens, passwords, and private keys before pushing
const SECRET_PATTERNS = [
  { name: 'GitHub Personal Access Token (classic)', regex: /ghp_[a-zA-Z0-9]{36}/ },
  { name: 'GitHub Fine-grained PAT', regex: /github_pat_[a-zA-Z0-9_]{50,100}/ },
  { name: 'Generic Bearer Token in code', regex: /Bearer\s+["']?[a-zA-Z0-9_\-\.]{30,}["']?/ },
  { name: 'Private Key block', regex: /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/ },
  { name: 'Supabase Service Role Key', regex: /eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+/ }
];

function scanForExposedSecrets(files) {
  console.log(`\n🛡️ Ejecutando escáner de secretos (Secret Scanner) sobre ${files.length} archivos...`);
  const leaks = [];

  for (const file of files) {
    // Solo escanear archivos de texto/código (omitir imágenes o binarios)
    const ext = path.extname(file.fullPath).toLowerCase();
    if (['.png', '.jpg', '.jpeg', '.gif', '.ico', '.pdf', '.docx', '.xlsx', '.pptx'].includes(ext)) {
      continue;
    }

    try {
      const content = fs.readFileSync(file.fullPath, 'utf8');
      const lines = content.split('\n');

      for (let lineNum = 0; lineNum < lines.length; lineNum++) {
        const line = lines[lineNum];
        // Ignorar líneas de ejemplo/plantillas
        if (line.includes('AQUI_PEGA_TU') || line.includes('ejemplo') || line.includes('YOUR_TOKEN')) continue;

        for (const pattern of SECRET_PATTERNS) {
          if (pattern.regex.test(line)) {
            leaks.push({
              file: file.relativePath,
              line: lineNum + 1,
              secretType: pattern.name
            });
          }
        }
      }
    } catch (e) {
      // Ignorar errores de lectura binaria
    }
  }

  if (leaks.length > 0) {
    console.error('\n🚨 ¡ALERTA DE SEGURIDAD CRÍTICA! Se detectaron posibles credenciales expuestas:');
    leaks.forEach(leak => {
      console.error(`   ❌ [${leak.secretType}] en ${leak.file} (Línea ${leak.line})`);
    });
    console.error('\n🛑 Subida cancelada automáticamente para proteger tus credenciales personales.');
    process.exit(1);
  }

  console.log('✅ Escáner superado: 0 secretos expuestos.');
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

// targetMode: 'team_only' (solo .agents, reglas, setup) | 'projects_only' (solo Projects/)
function getWorkspaceFiles(dir, targetMode = 'team_only', fileList = []) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (shouldIgnore(file, stat)) continue;

    const relPath = path.relative(WORKSPACE_DIR, fullPath).replace(/\\/g, '/');
    const isProjectsPath = relPath === 'Projects' || relPath.startsWith('Projects/');

    if (targetMode === 'team_only' && isProjectsPath) {
      continue; // Excluir Projects/ para el repositorio de equipo
    }

    if (targetMode === 'projects_only' && !isProjectsPath) {
      continue; // Excluir .agents/ y framework para el repositorio exclusivo de proyectos
    }

    if (stat.isDirectory()) {
      getWorkspaceFiles(fullPath, targetMode, fileList);
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
  const startTime = Date.now();
  console.log(`\n🚀 Analizando diferencias (Git Delta) en '${OWNER}/${repoName}' (${files.length} archivos locales)...`);
  
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

  // 1. Obtener el árbol remoto actual de GitHub
  let remoteTreeMap = new Map();
  try {
    const remoteTreeData = await ghApi(`/repos/${OWNER}/${repoName}/git/trees/${parentTreeSha}?recursive=1`);
    if (remoteTreeData && Array.isArray(remoteTreeData.tree)) {
      remoteTreeData.tree.forEach(item => {
        if (item.type === 'blob') {
          remoteTreeMap.set(item.path, item.sha);
        }
      });
    }
  } catch (e) {
    console.log(`   ⚠️ No se pudo obtener el árbol recursivo previo; se evaluará subida completa.`);
  }

  // 2. Comparar Hash local con Hash remoto (Diferencial)
  const treeEntries = [];
  let uploadedCount = 0;
  let reusedCount = 0;

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const fileBuffer = fs.readFileSync(file.fullPath);
    const localSha = computeGitBlobSha(fileBuffer);
    const remoteSha = remoteTreeMap.get(file.relativePath);

    let targetSha = remoteSha;
    if (remoteSha && remoteSha === localSha) {
      // El archivo es idéntico: reutilizamos el SHA sin hacer peticiones HTTP
      reusedCount++;
    } else {
      // El archivo es nuevo o ha sido modificado: subimos el blob a GitHub
      const base64Content = fileBuffer.toString('base64');
      const blobData = await ghApi(`/repos/${OWNER}/${repoName}/git/blobs`, 'POST', {
        content: base64Content,
        encoding: 'base64'
      });
      targetSha = blobData.sha;
      uploadedCount++;
      console.log(`   📤 [MODIFICADO/NUEVO] ${file.relativePath}`);
    }

    treeEntries.push({
      path: file.relativePath,
      mode: '100644',
      type: 'blob',
      sha: targetSha
    });
  }

  // 3. Comprobar si hubo cambios reales
  if (uploadedCount === 0) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
    console.log(`⚡ Repositorio '${OWNER}/${repoName}' ya está 100% al día (${reusedCount} archivos verificados en ${elapsed}s, 0 cambios detectados).`);
    return;
  }

  console.log(`   📊 Resumen Delta: ${uploadedCount} subido(s), ${reusedCount} sin cambios.`);

  // 4. Construcción limpia del árbol de Git
  console.log(`   🌳 Creando árbol de Git limpio de forma incremental...`);
  const BATCH_SIZE = 80;
  let currentBaseTreeSha = undefined; // Árbol limpio que solo contiene los archivos explícitos de este repositorio

  for (let b = 0; b < treeEntries.length; b += BATCH_SIZE) {
    const chunk = treeEntries.slice(b, b + BATCH_SIZE);
    const body = currentBaseTreeSha 
      ? { base_tree: currentBaseTreeSha, tree: chunk }
      : { tree: chunk };
      
    const chunkTreeData = await ghApi(`/repos/${OWNER}/${repoName}/git/trees`, 'POST', body);
    currentBaseTreeSha = chunkTreeData.sha;
  }

  // 5. Crear Commit y actualizar rama
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

  const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
  console.log(`✅ Repositorio '${OWNER}/${repoName}' sincronizado exitosamente en ${elapsed}s.`);
}

async function run() {
  console.log('🔍 Escaneando y clasificando archivos locales...');

  // 1. Repositorio de Equipo: SOLO framework (.agents/, setup.bat, guías). NUNCA Projects/
  const teamFiles = getWorkspaceFiles(WORKSPACE_DIR, 'team_only');
  console.log(`📦 Archivos para el Repositorio de Equipo ('${TEAM_REPO}'): ${teamFiles.length}`);

  // 2. Repositorio de Proyectos: SOLO Projects/. NUNCA .agents/ ni configuración del framework
  const projectFiles = getWorkspaceFiles(WORKSPACE_DIR, 'projects_only');
  console.log(`🔒 Archivos para el Repositorio Exclusivo de Proyectos ('${PRIVATE_REPO}'): ${projectFiles.length}`);

  // 3. Ejecutar Escáner de Seguridad en todos los archivos antes de cualquier subida
  scanForExposedSecrets(teamFiles.concat(projectFiles));

  try {
    const reposToSync = [
      {
        name: TEAM_REPO,
        files: teamFiles,
        description: 'Suite de Agentes, Reglas, Workflows y Estándares de HIBERUS (Read-Only para Equipo)',
        message: 'Update team framework: .agents profiles and onboarding assets'
      },
      {
        name: PRIVATE_REPO,
        files: projectFiles,
        description: 'Repositorio Privado Exclusivo de Proyectos y Entregables de Clientes SAP HIBERUS',
        message: 'Update private customer projects and deliverables'
      }
    ];

    for (const target of reposToSync) {
      await ensureRepo(target.name, target.description);
      await pushToRepo(target.name, target.files, target.message);
    }

    console.log('\n🎉 ¡PROCESO FINALIZADO CON ÉXITO Y AISLAMIENTO TOTAL!');
    console.log(`- Repo 1 (Framework Equipo - Solo .agents/): https://github.com/${OWNER}/${TEAM_REPO}`);
    console.log(`- Repo 2 (Privado Clientes - Solo Projects/): https://github.com/${OWNER}/${PRIVATE_REPO}`);
  } catch (err) {
    console.error('\n❌ Error durante la publicación:', err.message);
  }
}

run();
