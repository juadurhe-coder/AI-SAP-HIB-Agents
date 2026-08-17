/**
 * ==============================================================================
 * SCRIPT: check-governance.js
 * OBJETIVO: Linter de Gobernanza, Integridad de Scripts, Plantillas, Kanban y Tablas (Multi-Agente)
 * Carga dinámicamente el catálogo SSOT desde Standards/document_types.json.
 * Auditoría de integridad de código, metadatos, enlaces, placeholders, memoria, Kanban y sintaxis de tablas.
 * ==============================================================================
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { scanFilesRecursively, readJsonSafe, logAndAccumulate } = require('../utils/common-utils');

const projectsDir = path.join(__dirname, '..', '..', '..', 'Projects');
const docTypesPath = path.join(__dirname, '..', '..', 'Standards', 'document_types.json');

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
  const scriptIntegrityPath = path.join(__dirname, '..', 'tests', 'Test-ScriptIntegrity.ps1');
  if (fs.existsSync(scriptIntegrityPath)) {
    execSync(`powershell -NoProfile -ExecutionPolicy Bypass -File "${scriptIntegrityPath}"`, { encoding: 'utf8' });
    console.log('✅ Integridad de scripts verificada exitosamente.\n');
  }
} catch (e) {
  console.error('❌ ERROR FATAL en la integridad de scripts:');
  console.error(e.stdout || e.message);
  process.exit(1);
}

// 0.1 Auditoría de especificaciones y código ABAP & Fiori (Clean Code & Clean Core)
const { checkSpecGovernance } = require('../checkers/abap/check-abap-spec-governance.js');
const { checkRefactoring } = require('../checkers/abap/check-abap-clean-code-refactoring.js');
const { checkQuality } = require('../checkers/abap/check-abap-clean-code-quality.js');
const { checkRobustness } = require('../checkers/abap/check-abap-robustness-nulls.js');
const { checkSecurity } = require('../checkers/abap/check-abap-security.js');
const { checkPerformance } = require('../checkers/abap/check-abap-performance.js');

const { checkFioriSpecGovernance } = require('../checkers/fiori/check-fiori-spec-governance.js');
const { checkFioriQuality } = require('../checkers/fiori/check-fiori-clean-code-quality.js');

console.log('🛡️  Auditando especificaciones y desarrollos ABAP & Fiori...');

const counters = { totalPassed: 0, totalWarnings: 0, totalErrors: 0 };

// 1. Descubrimiento de archivos ABAP / CDS / BDEF
const abapFilesFound = scanFilesRecursively(projectsDir, name => {
  const ext = path.extname(name).toLowerCase();
  return ext === '.abap' || ext === '.cds' || ext === '.bdef';
}, ['node_modules', '.git', '99_archive', 'dist']);

if (abapFilesFound.length > 0) {
  console.log(`   🔎 Encontrados ${abapFilesFound.length} archivo(s) ABAP/CDS/RAP para auditoría:`);
  abapFilesFound.forEach(f => {
    const qRes = checkQuality(f, true);
    const rRes = checkRefactoring(f, true);
    const robRes = checkRobustness(f, true);
    const secRes = checkSecurity(f, true);
    const perfRes = checkPerformance(f, true);
    const merged = {
      errors: [...qRes.errors, ...rRes.errors, ...robRes.errors, ...secRes.errors, ...perfRes.errors],
      warnings: [...qRes.warnings, ...rRes.warnings, ...robRes.warnings, ...secRes.warnings, ...perfRes.warnings]
    };
    logAndAccumulate(merged, counters, `Código ABAP/CDS: ${path.basename(f)}`);
  });
} else {
  console.log('   ℹ️  No se encontraron archivos .abap o .cds en Projects/');
}

// 2. Descubrimiento de Aplicaciones Fiori (carpetas con manifest.json)
const fioriManifests = scanFilesRecursively(projectsDir, name => name.toLowerCase() === 'manifest.json', ['node_modules', '.git', '99_archive', 'dist']);
const fioriAppsFound = fioriManifests.map(m => {
  const p = path.dirname(m);
  return path.basename(p).toLowerCase() === 'webapp' ? path.dirname(p) : p;
});
const uniqueFioriApps = [...new Set(fioriAppsFound)];

if (uniqueFioriApps.length > 0) {
  console.log(`   🔎 Encontradas ${uniqueFioriApps.length} aplicación(es) Fiori/SAPUI5:`);
  uniqueFioriApps.forEach(appFolder => {
    const fioriRes = checkFioriQuality(appFolder);
    logAndAccumulate(fioriRes, counters, `App Fiori: ${path.basename(appFolder)}`);
  });
} else {
  console.log('   ℹ️  No se encontraron proyectos Fiori con manifest.json en Projects/');
}

// 3. Descubrimiento de Especificaciones Técnicas (04_TS*.md / *TS*.md)
const tsSpecsFound = scanFilesRecursively(projectsDir, name => {
  const lower = name.toLowerCase();
  return lower.endsWith('.md') && (lower.includes('04_ts') || lower.includes('_ts_') || lower.includes('technical_spec'));
}, ['node_modules', '.git', '99_archive', 'dist']);

if (tsSpecsFound.length > 0) {
  console.log(`   🔎 Encontradas ${tsSpecsFound.length} especificación(es) técnica(s):`);
  tsSpecsFound.forEach(specFile => {
    const baseName = path.basename(specFile).toLowerCase();
    const isUi = /\b(ui|frontend|fiori|sapui5)\b/i.test(baseName) || /_ui_|_frontend_|_fiori_/i.test(baseName);
    const specRes = isUi ? checkFioriSpecGovernance(specFile) : checkSpecGovernance(specFile);
    logAndAccumulate(specRes, counters, null);
  });
}
console.log('');

let totalPassed = counters.totalPassed;
let totalWarnings = counters.totalWarnings;
let totalErrors = counters.totalErrors;

// Carga de la Fuente Única de Verdad (SSOT)
const docTypesCatalog = readJsonSafe(docTypesPath, { types: [] });
const prefixMap = {};
(docTypesCatalog.types || []).forEach(t => {
  prefixMap[t.prefix] = `${t.code} - ${t.name}`;
});

// Archivos de código o desarrollo de app web a ignorar en auditorías de entregables
const ignoredDevFiles = [
  'package.json', 'package-lock.json', 'vite.config.js', 'tailwind.config.js',
  'postcss.config.js', 'schema.sql', 'README.md', 'index.html', '.gitignore'
];

const tempFileRegex = /(\(\d+\)|_copia|_OLD|_vOLD|\.resolved|copia of)/i;
const placeholderRegex = /\[(?:Completar|Insertar|Rellenar|Nombre del Rol|Nombre del Negocio|Definir|TBD|TODO|PENDIENTE)[^\]]*\]/i;

function auditMarkdownTables(content, fileName) {
  let tableWarnings = 0;
  const lines = content.split('\n');
  let inTable = false;
  let headerCols = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith('|') && line.endsWith('|')) {
      const cols = line.split('|').filter((_, idx, arr) => idx > 0 && idx < arr.length - 1);
      if (!inTable) {
        inTable = true;
        headerCols = cols.length;
      } else {
        if (line.match(/^\|[\s:\-|]+\|$/)) continue;
        if (cols.length !== headerCols) {
          console.log(`   ⚠️  [WARN] Entregable ${fileName}: Tabla Markdown desalineada en línea ${i+1} (${cols.length} cols vs ${headerCols} en cabecera)`);
          tableWarnings++;
        }
      }
    } else {
      inTable = false;
      headerCols = 0;
    }
  }
  return tableWarnings;
}

const subdirs = fs.readdirSync(projectsDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory() && dirent.name !== '99_Archive');

for (const dir of subdirs) {
  const projectPath = path.join(projectsDir, dir.name);
  console.log(`📁 Proyecto: ${dir.name}`);
  let dirErrors = 0;

  const metaPath = path.join(projectPath, '.project_metadata.json');
  const metaObj = readJsonSafe(metaPath, null);
  const metaProjectId = metaObj ? metaObj.project_id : null;

  if (metaObj) {
    const type = (metaObj.initiative_type || '').toLowerCase();
    const pid = (metaObj.project_id || '').toUpperCase();
    
    let expectedPrefix = null;
    if (type.includes('proyect') || type.includes('project')) expectedPrefix = 'PRJ-';
    else if (type.includes('change') || type.includes('cambio') || type.includes('mejora')) expectedPrefix = 'CR-';
    else if (type.includes('service') || type.includes('solicitud')) expectedPrefix = 'SR-';
    else if (type.includes('demand') || type.includes('demanda')) expectedPrefix = 'DEM-';
    else if (type.includes('incident') || type.includes('incidencia') || type.includes('bug')) expectedPrefix = 'INC-';

    if (expectedPrefix && !pid.startsWith(expectedPrefix)) {
      console.log(`   ⚠️  [WARN] .project_metadata.json: initiative_type '${metaObj.initiative_type}' requiere que project_id comience con '${expectedPrefix}' (actual: '${metaObj.project_id}')`);
      totalWarnings++;
    }
  }

  const files = fs.readdirSync(projectPath, { withFileTypes: true })
    .filter(f => f.isFile() && !f.name.startsWith('.'));

  if (metaProjectId) {
    for (const file of files) {
      const idMatch = file.name.match(/^\[([^\]]+)\]/);
      if (idMatch && idMatch[1] !== metaProjectId) {
        console.log(`   ⚠️  [WARN] ${file.name}: Prefijo [${idMatch[1]}] desalineado de project_id [${metaProjectId}] en .project_metadata.json. Ejecutar Sync-ProjectId.ps1`);
        totalWarnings++;
      }
    }
  }

  const memoryFile = files.find(f => f.name.startsWith('00_') || f.name.includes('_00_') || f.name.toLowerCase() === 'project_memory.md');
  if (!memoryFile) {
    console.log(`   ℹ️  [WARN] No contiene memoria persistente (00_Project_Memory.md)`);
    totalWarnings++;
  } else {
    const memPath = path.join(projectPath, memoryFile.name);
    try {
      const memContent = fs.readFileSync(memPath, 'utf8');
      const hasStructure = memContent.includes('METADATOS') || memContent.includes('Alcance') || memContent.includes('Objetivos') || memContent.includes('Project Memory');
      if (!hasStructure) {
        console.log(`   ⚠️  [WARN] Memoria ${memoryFile.name}: No sigue la estructura estándar.`);
        totalWarnings++;
      }
    } catch (e) {}
  }

  const kanbanFile = files.find(f => f.name.toLowerCase().includes('kanban') && f.name.endsWith('.md'));
  if (!kanbanFile) {
    console.log(`   ℹ️  [WARN] No contiene tablero Kanban interactivo (*_Kanban.md)`);
    totalWarnings++;
  }

  for (const file of files) {
    const name = file.name;
    const filePath = path.join(projectPath, name);

    if (ignoredDevFiles.includes(name) || name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.xlsx')) {
      continue;
    }

    if (tempFileRegex.test(name)) {
      console.log(`   ❌ [FAIL] Archivo temporal/duplicado detectado: ${name}`);
      dirErrors++;
      continue;
    }

    let isDocument = false;
    let matchedPrefix = null;
    for (const prefix of Object.keys(prefixMap)) {
      if (name.startsWith(prefix) || name.includes(`_${prefix}`)) {
        isDocument = true;
        matchedPrefix = prefix;
        break;
      }
    }

    if (!isDocument) {
      if (name.toLowerCase().includes('kanban') || name.toLowerCase().includes('memory') || name.startsWith('00_')) {
        // Permitido
      } else {
        console.log(`   ⚠️  [WARN] Archivo no clasificado en catálogo: ${name}`);
        totalWarnings++;
      }
    } else {
      if (matchedPrefix) {
        if (name.endsWith('.md')) {
          try {
            const content = fs.readFileSync(filePath, 'utf8');

            const hasMetadataTable = content.includes('| **Documento**') || content.includes('| Documento') || content.includes('<!-- METADATOS -->');
            if (!hasMetadataTable) {
              console.log(`   ⚠️  [WARN] Entregable ${name}: Falta bloque o tabla de metadatos formal en cabecera.`);
              totalWarnings++;
            }

            const hasPageBreak = content.includes('<!-- PAGE_BREAK -->');
            if (!hasPageBreak) {
              console.log(`   ⚠️  [WARN] Entregable ${name}: Falta separador de salto de página '<!-- PAGE_BREAK -->'.`);
              totalWarnings++;
            }

            const placeholderMatch = content.match(placeholderRegex);
            if (placeholderMatch) {
              console.log(`   ⚠️  [WARN] Entregable ${name}: Contiene placeholders sin rellenar ('${placeholderMatch[0]}')`);
              totalWarnings++;
            }

            const tableWarns = auditMarkdownTables(content, name);
            totalWarnings += tableWarns;

            let brokenLinks = 0;
            const linkMatches = content.matchAll(/\[(?:[^\]]+)\]\((file:\/\/\/[^)]+|\.\/[^)]+|\.\.\/[^)]+)\)/g);
            for (const linkMatch of linkMatches) {
              let rawLink = linkMatch[1];
              let resolvedLinkPath = rawLink;

              if (rawLink.startsWith('file:///')) {
                resolvedLinkPath = decodeURIComponent(rawLink.replace('file:///', ''));
                if (process.platform === 'win32' && resolvedLinkPath.startsWith('/')) {
                  resolvedLinkPath = resolvedLinkPath.substring(1);
                }
              } else {
                resolvedLinkPath = path.resolve(projectPath, rawLink);
              }

              resolvedLinkPath = resolvedLinkPath.split('#')[0];

              if (!fs.existsSync(resolvedLinkPath)) {
                console.log(`   ⚠️  [WARN] Entregable ${name}: Enlace roto a archivo inexistente (${path.basename(resolvedLinkPath)})`);
                totalWarnings++;
                brokenLinks++;
              }
            }

            if (hasMetadataTable && hasPageBreak && !placeholderMatch && tableWarns === 0 && brokenLinks === 0) {
              console.log(`   ✅ [PASS] ${name} (${prefixMap[matchedPrefix]} - Metadatos, PAGE_BREAK & Tablas OK)`);
              totalPassed++;
            } else {
              console.log(`   ℹ️  [CHECK] ${name} (${prefixMap[matchedPrefix]})`);
            }
          } catch (e) {
            console.log(`   ⚠️  No se pudo leer el archivo ${name}`);
          }
        } else {
          console.log(`   ✅ [PASS] ${name} (${prefixMap[matchedPrefix]})`);
          totalPassed++;
        }
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
