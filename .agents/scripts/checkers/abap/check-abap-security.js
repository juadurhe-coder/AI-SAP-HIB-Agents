/**
 * Script: check-abap-security.js
 * Propósito: Analizar código ABAP para detectar vulnerabilidades de seguridad
 *            (SQL Injection, omisión de Authority-Checks, Code Injection y credenciales hardcodeadas).
 */

const fs = require('fs');
const path = require('path');
const { getCleanLines, readJsonSafe, initAuditResult } = require('../../utils/common-utils');

const rulesPath = path.join(__dirname, '..', '..', 'tests', 'linters', 'abap-clean-code-rules.json');
const rules = readJsonSafe(rulesPath, {});

function checkSecurity(codeOrPath, isPath = false) {
    const results = initAuditResult();

    let content = codeOrPath;
    let fileName = 'codigo_abap';

    if (isPath || (typeof codeOrPath === 'string' && fs.existsSync(codeOrPath) && !codeOrPath.includes('\n'))) {
        fileName = path.basename(codeOrPath);
        content = fs.readFileSync(codeOrPath, 'utf-8');
    }

    const allLines = content.split('\n');
    const cleanLines = getCleanLines(content, { commentPrefixes: ['*', '"'], skipEmpty: true });

    let hasAuthorityCheckInScope = /AUTHORITY-CHECK\s+OBJECT/i.test(content);

    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (isComment) return;

        // 1. Detección de ABAP Code Injection / Insecure Statements
        const secPatterns = (rules.securityPatterns && rules.securityPatterns.prohibitedStatements) || [
            'INSERT REPORT', 'GENERATE SUBROUTINE POOL', 'DELETE REPORT'
        ];
        secPatterns.forEach(stmt => {
            const regex = new RegExp(`\\b${stmt.replace(/\s+/g, '\\s+')}\\b`, 'i');
            if (regex.test(trimmed)) {
                results.errors.push(`[${fileName}:L${lineNum}] Insecure Statement: Uso de instrucción de alto riesgo '${stmt}'. Riesgo de inyección de código ABAP.`);
            }
        });

        // 2. Detección de Hardcoded Secrets / Credentials
        const credKeywords = (rules.securityPatterns && rules.securityPatterns.sensitiveCredentialKeywords) || [
            'password', 'passwd', 'secret_key', 'api_key', 'bearer_token'
        ];
        credKeywords.forEach(kw => {
            const regex = new RegExp(`\\b${kw}\\b\\s*=\\s*'([^']{3,})'`, 'i');
            const match = trimmed.match(regex);
            if (match && !/c_placeholder|initial|space/i.test(match[1])) {
                results.errors.push(`[${fileName}:L${lineNum}] Hardcoded Secret: Asignación directa de clave o contraseña sensible ('${kw} = ***'). Utilice Secure Storage o SAP Destination.`);
            }
        });

        // 3. Detección de SQL Injection en cláusulas WHERE dinámicas
        if (/SELECT\s+.*WHERE\s+\([A-Za-z0-9_]+\)/i.test(trimmed) || /WHERE\s+\([A-Za-z0-9_]+\)/i.test(trimmed)) {
            const prevContext = allLines.slice(Math.max(0, lineNum - 12), lineNum - 1).join('\n');
            const usesDynPrg = /cl_abap_dyn_prg=>/i.test(prevContext);
            if (!usesDynPrg) {
                results.errors.push(`[${fileName}:L${lineNum}] SQL Injection Risk: Uso de cláusula WHERE dinámica '(var)' sin sanitización previa con 'cl_abap_dyn_prg'.`);
            }
        }

        // 4. Modificación de Base de Datos sin Authority-Check
        if (/^(INSERT|UPDATE|DELETE|MODIFY)\s+[A-Za-z0-9_]+\s+FROM/i.test(trimmed) || /^DELETE\s+FROM\s+[A-Za-z0-9_]+/i.test(trimmed)) {
            if (!hasAuthorityCheckInScope) {
                results.errors.push(`[${fileName}:L${lineNum}] Missing Authorization: Operación DML sobre base de datos sin 'AUTHORITY-CHECK OBJECT' detectado en el componente.`);
            }
        }

        // 5. Filtrado por MANDT en lugar de USING CLIENT
        if (/WHERE\s+.*mandt\s*=\s*/i.test(trimmed) && !/USING\s+CLIENT/i.test(trimmed)) {
            results.warnings.push(`[${fileName}:L${lineNum}] Mandant-Security: Filtro explícito sobre 'mandt' detectado. Utilice la cláusula estándar 'USING CLIENT' de OpenSQL.`);
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
        console.log("Uso: node check-abap-security.js <path-to-file.abap>");
        process.exit(1);
    }
    const res = checkSecurity(targetFile, true);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkSecurity };
