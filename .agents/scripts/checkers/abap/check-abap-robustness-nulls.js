/**
 * Script: check-abap-robustness-nulls.js
 * Propósito: Analizar código ABAP para prevenir fallos en tiempo de ejecución (Short Dumps)
 *            por Field Symbols no asignados o referencias nulas, evitando falsos positivos.
 */

const fs = require('fs');
const path = require('path');
const { getCleanLines, initAuditResult } = require('../../utils/common-utils');

function checkRobustness(codeOrPath, isPath = false) {
    const results = initAuditResult();

    let content = codeOrPath;
    let fileName = 'codigo_abap';

    if (isPath || (typeof codeOrPath === 'string' && fs.existsSync(codeOrPath) && !codeOrPath.includes('\n'))) {
        fileName = path.basename(codeOrPath);
        content = fs.readFileSync(codeOrPath, 'utf-8');
    }

    const allLines = content.split('\n');
    const cleanLines = getCleanLines(content, { commentPrefixes: ['*', '"'], skipEmpty: true });

    let inLoopAssigning = null;

    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (isComment) return;

        // 1. Rastrear inicio y fin de loops con ASSIGNING
        const loopMatch = trimmed.match(/^LOOP\s+AT\s+.*\s+ASSIGNING\s+(<[A-Za-z0-9_]+>)/i);
        if (loopMatch) {
            inLoopAssigning = loopMatch[1].toUpperCase();
        } else if (/^ENDLOOP\b/i.test(trimmed)) {
            inLoopAssigning = null;
        }

        // 2. Comprobar acceso a Field Symbols (<FS_...>)
        const fsAccessMatch = trimmed.match(/(<[A-Za-z0-9_]+>)(?:-[A-Za-z0-9_]+)?/i);
        if (fsAccessMatch) {
            const fsName = fsAccessMatch[1].toUpperCase();

            if (inLoopAssigning !== fsName && !/^(FIELD-SYMBOLS:|ASSIGN\s+|READ\s+TABLE\s+.*ASSIGNING|LOOP\s+AT\s+.*ASSIGNING|IF\s+.*IS\s+ASSIGNED)/i.test(trimmed)) {
                const prevContext = allLines.slice(Math.max(0, lineNum - 9), lineNum - 1).join('\n');
                const hasAssignedCheck = new RegExp(`IS\\s+ASSIGNED|sy-subrc\\s*=\\s*0|ASSIGN\\s+.*TO\\s+${fsName.replace('<','\\<').replace('>','\\>')}`, 'i').test(prevContext);

                if (!hasAssignedCheck) {
                    results.errors.push(`[${fileName}:L${lineNum}] Uso de Field Symbol '${fsName}' sin verificar previamente 'IF ${fsName} IS ASSIGNED.' o 'sy-subrc = 0'.`);
                }
            }
        }

        // 3. Comprobar llamadas a métodos sobre objetos (LO_...-> / GO_...->)
        const objCallMatch = trimmed.match(/^(LO_[A-Za-z0-9_]+|GO_[A-Za-z0-9_]+)->[A-Za-z0-9_]+\s*\(/i);
        if (objCallMatch) {
            const objName = objCallMatch[1];
            const prevContext = allLines.slice(Math.max(0, lineNum - 11), lineNum - 1).join('\n');
            const isInstantiatedOrChecked = new RegExp(
                `${objName}\\s*=\\s*(NEW|CAST|zcl_|lcl_)|CREATE\\s+OBJECT\\s+${objName}|${objName}\\s+IS\\s+BOUND|${objName}\\s+IS\\s+NOT\\s+INITIAL`,
                'i'
            ).test(prevContext);

            if (!isInstantiatedOrChecked) {
                results.warnings.push(`[${fileName}:L${lineNum}] Invocación sobre '${objName}' sin instanciación visible reciente ni comprobación 'IF ${objName} IS BOUND.'.`);
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
        console.log("Uso: node check-abap-robustness-nulls.js <path-to-file.abap>");
        process.exit(1);
    }
    const res = checkRobustness(targetFile, true);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkRobustness };
