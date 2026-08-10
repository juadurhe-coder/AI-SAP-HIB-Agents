/**
 * ==============================================================================
 * SCRIPT: check-governance.js
 * OBJETIVO: Linter de Gobernanza, Integridad de Scripts y Cumplimiento (Multi-Agente)
 * Carga dinámicamente el catálogo SSOT desde Standards/document_types.json.
 * Auditoría de integridad de código, metadatos y control de archivado.
 * ==============================================================================
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const projectsDir = path.join(__dirname, '..', '..', 'Projects');
const docTypesPath = path.join(__dirname, '..', 'Standards', 'document_types.json');

console.log('========================================================================');
console.log(' 🛡️  AUDITORÍA DE GOBERNANZA MULTI-AGENTE Y PLANTILLAS (PROJECT LINTER)');
console.log('========================================================================');
console.log(`Ruta auditada: ${projectsDir}\n`);

if (!fs.existsSync(projectsDir)) {
  console.error(`❌ Error: La ruta ${projectsDir} no existe.`);
  process.exit(1);
}

if (!fs.existsSync(docTypesPath)) {
  console.error(`❌ Error: La fuente única de verdad ${docTypesPath} no existe.`);
  process.exit(1);
}

// 0. Auditoría previa de Integridad de Scripts (.agents/scripts/)
try {
  console.log('🔬 Ejecutando auditoría de integridad de scripts (.agents/scripts/)...');
  const scriptIntegrityPath = path.join(__dirname, 'Test-ScriptIntegrity.ps1');
  if (fs.existsSync(scriptIntegrityPath)) {
    const out = execSync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${scriptIntegrityPath}"`, { encoding: 'utf8' });
    console.log('✅ Integridad de scripts verificada exitosamente.\n');
  }
} catch (e) {
  console.error('❌ Error de integridad en scripts (.agents/scripts/):');
  console.error(e.stdout || e.message);
  process.exit(1);
}

// Carga de la Fuente Única de Verdad (SSOT)
const docTypesCatalog = JSON.parse(fs.readFileSync(docTypesPath, 'utf8'));
const allowedPrefixes = docTypesCatalog.types.map(t => t.prefix);
const prefixMap = {};
docTypesCatalog.types.forEach(t => {
  prefixMap[t.prefix] = `${t.code} - ${t.name}`;
});

// Archivos de código o desarrollo de app web a ignorar en auditorías de entregables
const ignoredDevFiles = [
  'package.json', 'package-lock.json', 'vite.config.js', 'tailwind.config.js',
  'postcss.config.js', 'schema.sql', 'README.md', 'index.html', '.gitignore'
];

let totalPassed = 0;
let totalWarnings = 0;
let totalErrors = 0;

const subdirs = fs.readdirSync(projectsDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory() && dirent.name !== '99_Archive');

for (const dir of subdirs) {
  const projectPath = path.join(projectsDir, dir.name);
  console.log(`📁 Proyecto: ${dir.name}`);
  let dirErrors = 0;

  const files = fs.readdirSync(projectPath, { withFileTypes: true })
    .filter(f => f.isFile() && !f.name.startsWith('.'));

  // 1. Comprobar memoria de proyecto (00_)
  const hasMemory = files.some(f => f.name.startsWith('00_') || f.name.includes('_00_') || f.name.toLowerCase() === 'project_memory.md');
  if (!hasMemory) {
    console.log(`   ℹ️  [WARN] No contiene memoria persistente (00_Project_Memory.md)`);
    totalWarnings++;
  } else {
    console.log(`   ℹ️  Memoria del proyecto detectada`);
  }

  // 2. Comprobar versiones desfasadas o duplicados en raíz
  const versionMap = {};
  for (const file of files) {
    const match = file.name.match(/^(.*?)_v(\d+)(\.\d+)?(\..*)$/);
    if (match) {
      const family = (match[1] + match[4]).toLowerCase();
      const versionNum = parseFloat(match[2] + (match[3] || '.0'));
      if (!versionMap[family]) versionMap[family] = [];
      versionMap[family].push({ name: file.name, version: versionNum });
    }
  }

  for (const family in versionMap) {
    if (versionMap[family].length > 1) {
      const maxVer = Math.max(...versionMap[family].map(v => v.version));
      for (const item of versionMap[family]) {
        if (item.version < maxVer) {
          console.log(`   ⚠️  [WARN] Versión superada en raíz: ${item.name} (existe v${maxVer}). Ejecutar Archive-OutdatedVersions.ps1`);
          totalWarnings++;
        }
      }
    }
  }

  // 3. Auditar cada archivo
  for (const file of files) {
    const name = file.name;

    if (ignoredDevFiles.includes(name)) {
      continue; // Omitir archivos de desarrollo de aplicaciones web
    }

    // Extraer prefijo posicionado al inicio o tras el [ID_Trazabilidad]
    const match = name.match(/^(?:\[[^\]]+\]_)?(0[0-8]_)/);
    const matchedPrefix = match ? match[1] : null;

    if (!matchedPrefix) {
      const ext = path.extname(name).toLowerCase();
      const isAuxiliary = name.toLowerCase().includes('mockup') || 
                          ['.html', '.htm', '.py', '.ps1', '.json', '.xlsx', '.pdf', '.txt', '.docx', '.doc', '.pptx', '.mp4', '.png', '.jpg', '.jpeg', '.csv'].includes(ext);

      if (isAuxiliary && !name.endsWith('.md')) {
        console.log(`   ⚠️  [WARN] Archivo auxiliar / exportación binaria sin prefijo numérico estándar: ${name}`);
        totalWarnings++;
      } else {
        console.log(`   ❌ [ERROR] Nomenclatura no estándar (falta prefijo numérico oficial 00_-08_): ${name}`);
        dirErrors++;
      }
    } else {
      // Inconsistencias cruzadas de prefijo
      if (matchedPrefix === '01_' && (name.includes('_FS_') || name.toLowerCase().includes('functional_spec'))) {
        console.log(`   ❌ [ERROR] Inconsistencia: Documento FS (${name}) usa prefijo 01_ en lugar de 03_FS`);
        dirErrors++;
      } else if ((matchedPrefix === '02_' || matchedPrefix === '03_') && (name.includes('_Proposal_') || name.toLowerCase().includes('propuesta'))) {
        console.log(`   ❌ [ERROR] Inconsistencia: Propuesta (${name}) usa prefijo ${matchedPrefix} en lugar de 01_PR`);
        dirErrors++;
      } else {
        // Validación de contenido en entregables Markdown
        if (name.endsWith('.md') && matchedPrefix !== '00_') {
          const filePath = path.join(projectPath, name);
          try {
            const content = fs.readFileSync(filePath, 'utf8');
            const hasMetadataTable = content.includes('Document Metadata') || content.includes('Metadatos') || content.includes('Project Metadata');
            const hasPageBreak = content.includes('[PAGE_BREAK]');

            if (!hasMetadataTable) {
              console.log(`   ⚠️  [WARN] Entregable ${name}: Falta la tabla de metadatos oficial (Document Metadata)`);
              totalWarnings++;
            }
            if (!hasPageBreak) {
              console.log(`   ⚠️  [WARN] Entregable ${name}: Falta salto de página [PAGE_BREAK] entre secciones`);
              totalWarnings++;
            }

            if (hasMetadataTable && hasPageBreak) {
              console.log(`   ✅ [PASS] ${name} (${prefixMap[matchedPrefix]} - Metadatos & PAGE_BREAK OK)`);
            } else {
              console.log(`   ℹ️  [CHECK] ${name} (${prefixMap[matchedPrefix]})`);
            }
          } catch (e) {
            console.log(`   ⚠️  No se pudo leer el archivo ${name}`);
          }
        } else {
          console.log(`   ✅ [PASS] ${name} (${prefixMap[matchedPrefix]})`);
        }
        totalPassed++;
      }
    }
  }

  totalErrors += dirErrors;
  console.log('');
}

console.log('========================================================================');
console.log(' 📊 RESUMEN DE LA AUDITORÍA DE GOBERNANZA Y PLANTILLAS');
console.log('========================================================================');
console.log(`Archivos Correctos (PASS) : ${totalPassed}`);
console.log(`Advertencias (WARN)      : ${totalWarnings}`);
console.log(`Errores (FAIL)           : ${totalErrors}`);

if (totalErrors > 0) {
  console.log(`\n❌ AUDITORÍA FALLIDA: Se detectaron ${totalErrors} error(es) de gobernanza.`);
  process.exit(1);
} else {
  console.log(`\n✅ AUDITORÍA EXITOSA: La estructura de proyectos y plantillas cumple las reglas de gobernanza.`);
  process.exit(0);
}
