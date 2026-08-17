/**
 * ==============================================================================
 * LINTER ESPECIALIZADO: test-javascript.js
 * Auditoría Clean Code y Sintaxis para scripts JavaScript (.js)
 * Detecta: errores de sintaxis, variables declaradas sin usar (let/const/var)
 * y bloques duplicados de código (nivel ERROR bloqueante).
 * ==============================================================================
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const scriptsDir = process.argv[2] || path.join(__dirname, '..', '..');

function getAllJsFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory() && entry.name !== 'node_modules' && entry.name !== 'fixtures' && entry.name !== '.git') {
      getAllJsFiles(fullPath, fileList);
    } else if (entry.isFile() && entry.name.endsWith('.js')) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

const jsFiles = getAllJsFiles(scriptsDir);

let totalPassed = 0;
let totalWarnings = 0;
let totalErrors = 0;

function testDuplicateBlocks(filePath, fileName) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split(/\r?\n/);
  const windowSize = 3;
  const cleanLines = [];

  for (let i = 0; i < lines.length; i++) {
    const t = lines[i].trim();
    if (t !== '' && t !== '{' && t !== '}' && t !== 'else' && !t.startsWith('//') && !t.startsWith('/*') && !t.startsWith('*')) {
      cleanLines.push({ lineNum: i + 1, content: t });
    }
  }

  const seenBlocks = new Map();
  let errorsCount = 0;

  if (cleanLines.length >= windowSize) {
    for (let i = 0; i <= cleanLines.length - windowSize; i++) {
      const blockKey = cleanLines.slice(i, i + windowSize).map(l => l.content).join('||');
      const startLine = cleanLines[i].lineNum;
      const endLine = cleanLines[i + windowSize - 1].lineNum;

      if (seenBlocks.has(blockKey)) {
        const prev = seenBlocks.get(blockKey);
        if (startLine > prev.endLine) {
          console.log(`\x1b[31m [ERROR BLOQUE DUPLICADO] ${fileName} (Líneas ${startLine}-${endLine} idénticas a ${prev.startLine}-${prev.endLine}). Refactorice a función o módulo común.\x1b[0m`);
          errorsCount++;
        }
      } else {
        seenBlocks.set(blockKey, { startLine, endLine });
      }
    }
  }
  return errorsCount;
}

function testUnusedVariables(filePath, fileName) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split(/\r?\n/);
  let errorsCount = 0;

  const declRegex = /(?:const|let|var)\s+([a-zA-Z_$][a-zA-Z0-9_$]*)\s*=/g;

  let match;
  while ((match = declRegex.exec(content)) !== null) {
    const varName = match[1];

    if (['fs', 'path', 'https', 'http', 'child_process', 'execSync', 'express'].includes(varName)) {
      continue;
    }

    const usages = content.split(new RegExp(`\\b${varName}\\b`, 'g')).length - 1;

    if (usages <= 1) {
      let lineNum = 1;
      for (let i = 0; i < lines.length; i++) {
        if (lines[i].includes(match[0])) {
          lineNum = i + 1;
          break;
        }
      }
      console.log(`\x1b[31m [ERROR VARIABLE HUÉRFANA] ${fileName} (Línea ${lineNum}): La variable '${varName}' está declarada pero nunca se utiliza.\x1b[0m`);
      errorsCount++;
    }
  }

  return errorsCount;
}

console.log('\x1b[33m--- AUDITANDO SCRIPTS JAVASCRIPT (.js) --- \x1b[0m');

for (const filePath of jsFiles) {
  const fileName = path.basename(filePath);
  let filePassed = true;

  // 1. Sintaxis con Node.js --check
  try {
    execSync(`node --check "${filePath}"`, { stdio: 'pipe' });
  } catch (err) {
    filePassed = false;
    totalErrors++;
    console.log(`\x1b[31m [ERROR SINTAXIS] ${fileName} tiene errores de sintaxis en Node.js:\x1b[0m`);
    console.log(`\x1b[31m    ${err.stderr ? err.stderr.toString().trim() : err.message}\x1b[0m`);
    continue;
  }

  // 2. Auditoría Clean Code JS (Variables no utilizadas)
  const unusedErrors = testUnusedVariables(filePath, fileName);
  if (unusedErrors > 0) {
    filePassed = false;
    totalErrors += unusedErrors;
  }

  // 3. Auditoría de bloques duplicados (Nivel ERROR)
  const dupErrors = testDuplicateBlocks(filePath, fileName);
  if (dupErrors > 0) {
    filePassed = false;
    totalErrors += dupErrors;
  }

  if (filePassed) {
    console.log(`\x1b[32m [PASS] ${fileName} (Node --check & Clean Code JS OK)\x1b[0m`);
    totalPassed++;
  }
}

const result = { passed: totalPassed, warnings: totalWarnings, errors: totalErrors };
process.stdout.write(JSON.stringify(result));
process.exit(totalErrors === 0 ? 0 : 1);
