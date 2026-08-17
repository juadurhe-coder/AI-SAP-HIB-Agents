/**
 * Script: common-utils.js
 * Propósito: Módulo de utilidades compartidas para los scripts de gobierno y linters
 *            (escaneo recursivo, lectura y filtrado de líneas, parseo seguro y reporte).
 */

const fs = require('fs');
const path = require('path');

/**
 * Escanea recursivamente un directorio buscando ficheros que cumplan con un predicado.
 */
function scanFilesRecursively(dir, filterFn, ignoreDirs = ['node_modules', '.git', 'dist', 'fixtures']) {
    const results = [];
    if (!fs.existsSync(dir)) return results;

    function walk(currentDir) {
        const entries = fs.readdirSync(currentDir, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
                if (!ignoreDirs.includes(entry.name.toLowerCase())) {
                    walk(fullPath);
                }
            } else if (entry.isFile()) {
                if (!filterFn || filterFn(entry.name, fullPath)) {
                    results.push(fullPath);
                }
            }
        }
    }

    walk(dir);
    return results;
}

/**
 * Divide el contenido en líneas y extrae información filtrando comentarios y líneas vacías.
 */
function getCleanLines(content, options = {}) {
    const { commentPrefixes = ['*', '"', '//', '/*', '<!--'], skipEmpty = true } = options;
    const lines = content.split('\n');
    const result = [];

    lines.forEach((rawLine, index) => {
        const trimmed = rawLine.trim();
        if (skipEmpty && trimmed === '') return;

        let isComment = false;
        for (const prefix of commentPrefixes) {
            if (trimmed.startsWith(prefix)) {
                isComment = true;
                break;
            }
        }

        result.push({
            raw: rawLine,
            trimmed: trimmed,
            lineNum: index + 1,
            isComment: isComment
        });
    });

    return result;
}

/**
 * Lee un archivo JSON de forma segura capturando posibles excepciones de sintaxis.
 */
function readJsonSafe(filePath, defaultValue = null) {
    try {
        if (!fs.existsSync(filePath)) return defaultValue;
        const text = fs.readFileSync(filePath, 'utf-8');
        return JSON.parse(text);
    } catch (e) {
        return defaultValue;
    }
}

/**
 * Inicializa la estructura estándar de resultados de auditoría.
 */
function initAuditResult() {
    return {
        errors: [],
        warnings: [],
        passed: true
    };
}

/**
 * Imprime y acumula los resultados de una auditoría en los contadores globales.
 */
function logAndAccumulate(res, counters, successLabel) {
    if (res.errors && res.errors.length > 0) {
        res.errors.forEach(err => console.log(`   ❌ [ERROR] ${err}`));
        counters.totalErrors += res.errors.length;
    }
    if (res.warnings && res.warnings.length > 0) {
        res.warnings.forEach(warn => console.log(`   ⚠️  [WARN] ${warn}`));
        counters.totalWarnings += res.warnings.length;
    }
    if (!res.errors || res.errors.length === 0) {
        if (successLabel) {
            console.log(`   ✅ [PASS] ${successLabel}`);
        }
        counters.totalPassed++;
    }
}

module.exports = {
    scanFilesRecursively,
    getCleanLines,
    readJsonSafe,
    initAuditResult,
    logAndAccumulate
};
