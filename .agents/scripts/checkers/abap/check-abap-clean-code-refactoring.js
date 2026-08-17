/**
 * Script: check-abap-clean-code-refactoring.js
 * Propósito: Analizar código ABAP para detectar código muerto/comentado, métodos largos,
 *            exceso de parámetros y anidamientos profundos.
 */

const fs = require('fs');
const path = require('path');
const { getCleanLines, readJsonSafe, initAuditResult } = require('../../utils/common-utils');

const rulesPath = path.join(__dirname, '..', '..', 'tests', 'linters', 'abap-clean-code-rules.json');
const rules = readJsonSafe(rulesPath, { metrics: { maxMethodParameters: 5, maxMethodLines: 50, maxNestingDepth: 3 } });

function checkRefactoring(codeOrPath, isPath = false) {
    const results = initAuditResult();

    let content = codeOrPath;
    let fileName = 'codigo_abap';

    if (isPath || (typeof codeOrPath === 'string' && fs.existsSync(codeOrPath) && !codeOrPath.includes('\n'))) {
        fileName = path.basename(codeOrPath);
        content = fs.readFileSync(codeOrPath, 'utf-8');
    }

    const cleanLines = getCleanLines(content, { commentPrefixes: ['*', '"'], skipEmpty: false });

    // 1. Detectar Código Comentado
    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (isComment && /\b(IF|LOOP\s+AT|SELECT|CALL\s+METHOD|MOVE|DATA\(|DATA:)\b/i.test(trimmed)) {
            results.errors.push(`[${fileName}:L${lineNum}] Código ABAP antiguo comentado detectado. Elimine el código y use el historial de Git.`);
        }
    });

    // 2. Detectar Métodos con Exceso de Parámetros y Métodos Largos
    let inMethodDef = false;
    let methodDefBuffer = '';
    let methodDefStartLine = 0;

    let currentMethod = null;
    let methodLineCount = 0;
    let nestingDepth = 0;

    function finishMethodDef(stmt, lineNum) {
        const match = stmt.match(/\bMETHODS(?::|\s+)\s*([A-Za-z0-9_]+)/i);
        const methodName = match ? match[1] : 'Desconocido';
        const paramMatches = stmt.match(/(IMPORTING|EXPORTING|CHANGING)\s+([^.]*)/i);
        if (paramMatches) {
            const count = (paramMatches[2].match(/\b(TYPE|LIKE)\b/gi) || []).length;
            if (count > rules.metrics.maxMethodParameters) {
                results.warnings.push(`[${fileName}:L${lineNum}] Método '${methodName}' tiene ${count} parámetros formales (máximo recomendado: ${rules.metrics.maxMethodParameters}). Considere agrupar en estructura o refactorizar.`);
            }
        }
    }

    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (trimmed === '') return;

        // Definición de métodos y parámetros
        if (!isComment) {
            if (/\bMETHODS(?::|\s+)\s*([A-Za-z0-9_]+)/i.test(trimmed)) {
                inMethodDef = true;
                methodDefBuffer = trimmed;
                methodDefStartLine = lineNum;
            } else if (inMethodDef) {
                methodDefBuffer += ' ' + trimmed;
            }

            if (inMethodDef && trimmed.endsWith('.')) {
                finishMethodDef(methodDefBuffer, methodDefStartLine);
                inMethodDef = false;
                methodDefBuffer = '';
            }

            // Implementación de métodos, conteo de líneas y anidamientos
            if (/^METHOD\s+([A-Za-z0-9_]+)/i.test(trimmed)) {
                const match = trimmed.match(/^METHOD\s+([A-Za-z0-9_]+)/i);
                currentMethod = match ? match[1] : 'Desconocido';
                methodLineCount = 0;
                nestingDepth = 0;
            } else if (/^ENDMETHOD/i.test(trimmed)) {
                if (methodLineCount > rules.metrics.maxMethodLines) {
                    results.errors.push(`[${fileName}] Método '${currentMethod}' excede el máximo de ${rules.metrics.maxMethodLines} líneas útiles (${methodLineCount} líneas). Considere usar Extract Method.`);
                }
                currentMethod = null;
                nestingDepth = 0;
            } else if (currentMethod) {
                methodLineCount++;
                if (/^(IF|LOOP\s+AT|DO|WHILE|CASE)\b/i.test(trimmed)) {
                    nestingDepth++;
                    if (nestingDepth > rules.metrics.maxNestingDepth) {
                        results.errors.push(`[${fileName}:L${lineNum}] Anidamiento excesivo en '${currentMethod}' (nivel ${nestingDepth}). Máximo permitido: ${rules.metrics.maxNestingDepth}.`);
                    }
                } else if (/^(ENDIF|ENDLOOP|ENDDO|ENDWHILE|ENDCASE)\b/i.test(trimmed)) {
                    nestingDepth = Math.max(0, nestingDepth - 1);
                }
            }
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
        console.log("Uso: node check-abap-clean-code-refactoring.js <path-to-file.abap>");
        process.exit(1);
    }
    const res = checkRefactoring(targetFile, true);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkRefactoring };
