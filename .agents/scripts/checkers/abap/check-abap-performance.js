/**
 * Script: check-abap-performance.js
 * Propósito: Analizar código ABAP para detectar antipatrones de rendimiento
 *            (SELECT *, SELECT en LOOP, FOR ALL ENTRIES sin verificación IS NOT INITIAL y MODIFY masivos).
 */

const fs = require('fs');
const path = require('path');
const { getCleanLines, initAuditResult } = require('../../utils/common-utils');

function checkPerformance(codeOrPath, isPath = false) {
    const results = initAuditResult();

    let content = codeOrPath;
    let fileName = 'codigo_abap';

    if (isPath || (typeof codeOrPath === 'string' && fs.existsSync(codeOrPath) && !codeOrPath.includes('\n'))) {
        fileName = path.basename(codeOrPath);
        content = fs.readFileSync(codeOrPath, 'utf-8');
    }

    const allLines = content.split('\n');
    const cleanLines = getCleanLines(content, { commentPrefixes: ['*', '"'], skipEmpty: true });

    let inLoop = false;
    let loopStartLine = 0;

    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (isComment) return;

        // Rastrear bloques LOOP AT
        if (/^LOOP\s+AT\s+/i.test(trimmed)) {
            inLoop = true;
            loopStartLine = lineNum;
        } else if (/^ENDLOOP\b/i.test(trimmed)) {
            inLoop = false;
        }

        // 1. Detección de SELECT *
        if (/SELECT\s+\*\s+FROM/i.test(trimmed)) {
            results.errors.push(`[${fileName}:L${lineNum}] Performance Anti-Pattern: Uso de 'SELECT *'. Especifique explícitamente solo las columnas necesarias para optimizar ancho de banda y memoria.`);
        }

        // 2. Detección de SELECT dentro de LOOP AT
        if (inLoop && /^SELECT\s+/i.test(trimmed)) {
            results.errors.push(`[${fileName}:L${lineNum}] High Performance Risk: Consulta 'SELECT' ejecutada dentro de un bloque 'LOOP AT' (iniciado en L${loopStartLine}). Utilice FOR ALL ENTRIES o JOINs relacionales.`);
        }

        // 3. Detección de FOR ALL ENTRIES sin comprobación 'IS NOT INITIAL'
        const faeMatch = trimmed.match(/FOR\s+ALL\s+ENTRIES\s+IN\s+([A-Za-z0-9_]+)/i);
        if (faeMatch) {
            const itabName = faeMatch[1];
            const prevContext = allLines.slice(Math.max(0, lineNum - 12), lineNum - 1).join('\n');
            const hasInitialCheck = new RegExp(`IF\\s+${itabName}\\s+IS\\s+NOT\\s+INITIAL|CHECK\\s+${itabName}\\s+IS\\s+NOT\\s+INITIAL`, 'i').test(prevContext);

            if (!hasInitialCheck) {
                results.errors.push(`[${fileName}:L${lineNum}] Critical Performance Risk: 'FOR ALL ENTRIES IN ${itabName}' sin verificar previamente 'IF ${itabName} IS NOT INITIAL.'. Si la tabla está vacía, SAP ejecutará un Full Table Scan.`);
            }
        }

        // 4. Detección de MODIFY sin TRANSPORTING o WHERE
        if (/^MODIFY\s+([A-Za-z0-9_]+)\s+FROM\s+/i.test(trimmed) && !/WHERE|TRANSPORTING|INDEX/i.test(trimmed)) {
            results.warnings.push(`[${fileName}:L${lineNum}] Performance Note: 'MODIFY' sobre tabla interna sin cláusula 'TRANSPORTING' ni 'WHERE'. Considere especificar solo los campos modificados.`);
        }
    });

    if (results.errors.length > 0) {
        results.passed = false;
    }

    return results;
}

if (require.main === module) {
    const targetFile = process.argv[2];
    if (!targetFile) {
        console.log("Uso: node check-abap-performance.js <path-to-file.abap>");
        process.exit(1);
    }
    const res = checkPerformance(targetFile, true);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkPerformance };
