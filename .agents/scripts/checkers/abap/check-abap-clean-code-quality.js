/**
 * Script: check-abap-clean-code-quality.js
 * Propósito: Analizar código ABAP y CDS para verificar Clean Code, Clean Core (Cloud Keywords),
 *            Naming Conventions, comentarios limpios, magic numbers y anotaciones CDS/RAP.
 */

const fs = require('fs');
const path = require('path');
const { getCleanLines, readJsonSafe, initAuditResult } = require('../../utils/common-utils');

const rulesPath = path.join(__dirname, '..', '..', 'tests', 'linters', 'abap-clean-code-rules.json');
const rules = readJsonSafe(rulesPath, {});

function checkQuality(codeOrPath, isPath = false) {
    const results = initAuditResult();

    let content = codeOrPath;
    let fileName = 'codigo_abap';

    if (isPath || (typeof codeOrPath === 'string' && fs.existsSync(codeOrPath) && !codeOrPath.includes('\n'))) {
        fileName = path.basename(codeOrPath);
        content = fs.readFileSync(codeOrPath, 'utf-8');
    }

    const cleanLines = getCleanLines(content, { commentPrefixes: ['*', '"'], skipEmpty: false });
    let isUiLayer = false;

    cleanLines.forEach(({ trimmed, lineNum, isComment }) => {
        if (trimmed === '') return;

        // 1. Comentarios Redundantes
        if (isComment) {
            const lowerComment = trimmed.toLowerCase();
            (rules.redundantCommentPhrases || []).forEach(phrase => {
                if (lowerComment.includes(phrase.toLowerCase())) {
                    results.errors.push(`[${fileName}:L${lineNum}] Comentario redundante detectado ("${phrase}"). El código debe ser autoexplicativo.`);
                }
            });
            return;
        }

        // 2. Keywords Prohibidos en ABAP Cloud
        (rules.prohibitedKeywordsInCloud || []).forEach(kw => {
            const regex = new RegExp(`\\b${kw.replace(/\s+/g, '\\s+')}\\b`, 'i');
            if (regex.test(trimmed)) {
                results.errors.push(`[${fileName}:L${lineNum}] Clean Core Violation: Uso de keyword prohibido en ABAP Cloud ('${kw}').`);
            }
        });

        // 3. Magic Numbers / Literales Hardcodeados
        const hasSystemLiteral = /sy-subrc\s*(=|<>|<=|>=|<|>)\s*0|space|abap_true|abap_false|initial/i.test(trimmed);
        if (!hasSystemLiteral) {
            if (/^(IF|ELSEIF|WHEN)\s+.*(=|EQ|NE|<>)\s*'([A-Za-z0-9_]{2,})'/i.test(trimmed)) {
                if (!/CONSTANTS|C_/i.test(trimmed)) {
                    results.errors.push(`[${fileName}:L${lineNum}] Literal de texto hardcodeado en condicional. Declare y use CONSTANTS (ej. C_STATUS_ACTIVE).`);
                }
            } else if (/^(IF|ELSEIF|WHEN)\s+.*(=|EQ|NE|<>)\s*(\d{2,})/i.test(trimmed)) {
                if (!/CONSTANTS|C_/i.test(trimmed)) {
                    results.errors.push(`[${fileName}:L${lineNum}] Magic Number detectado en condicional. Declare y use CONSTANTS.`);
                }
            }
        }

        // 4. Convenciones de Nomenclatura (Tablas, FS, Constantes)
        const tableDecl = trimmed.match(/\bDATA(?:\(\s*([a-zA-Z0-9_]+)\s*\)|:\s*([a-zA-Z0-9_]+))\s+(?:TYPE\s+(?:STANDARD\s+|SORTED\s+|HASHED\s+)?TABLE\s+OF|TYPE\s+TABLE\s+OF)\b/i);
        if (tableDecl) {
            const varName = tableDecl[1] || tableDecl[2];
            if (varName && !/^LT_[A-Z0-9_]+$/i.test(varName) && !/^GT_[A-Z0-9_]+$/i.test(varName)) {
                results.warnings.push(`[${fileName}:L${lineNum}] Naming Convention: La tabla interna '${varName}' debería comenzar con 'LT_' o 'GT_'.`);
            }
        }

        const fsDecl = trimmed.match(/\bFIELD-SYMBOLS:\s*(<[a-zA-Z0-9_]+>)/i);
        if (fsDecl) {
            const fsName = fsDecl[1];
            if (!/^<FS_[A-Z0-9_]+>$/i.test(fsName)) {
                results.warnings.push(`[${fileName}:L${lineNum}] Naming Convention: El Field Symbol '${fsName}' debería tener el formato '<FS_...>'.`);
            }
        }

        const constDecl = trimmed.match(/\bCONSTANTS(?::|\s+)\s*([a-zA-Z0-9_]+)\b/i);
        if (constDecl) {
            const constName = constDecl[1];
            if (!/^C_[A-Z0-9_]+$/i.test(constName)) {
                results.warnings.push(`[${fileName}:L${lineNum}] Naming Convention: La constante '${constName}' debería comenzar con 'C_'.`);
            }
        }

        // 5. Violación de SRP (SQL en capas de UI)
        if (/CLASS\s+ZCL_.*_UI\s+/i.test(trimmed) || /CLASS\s+ZCL_.*_CONTROLLER\s+/i.test(trimmed)) {
            isUiLayer = true;
        }
        if (isUiLayer && /^SELECT\s+/i.test(trimmed)) {
            results.errors.push(`[${fileName}:L${lineNum}] Violación SRP. No se permiten consultas 'SELECT' directas en clases de UI/Presentación. Use capas de Modelo/CDS Views.`);
        }
    });

    // 6. Validar Vistas CDS y Reglas RAP
    const isCds = fileName.endsWith('.cds') || /define\s+(root\s+)?view\s+entity/i.test(content);
    if (isCds) {
        // Anotaciones obligatorias
        (rules.requiredCdsAnnotations || []).forEach(annotation => {
            if (!content.includes(annotation)) {
                results.errors.push(`[${fileName}] Falta anotación CDS obligatoria: '${annotation}'.`);
            }
        });

        // Anotaciones recomendadas
        (rules.recommendedCdsAnnotations || []).forEach(annotation => {
            if (!content.includes(annotation)) {
                results.warnings.push(`[${fileName}] Se recomienda incluir la anotación CDS '${annotation}' para cumplimiento VDM/RAP.`);
            }
        });

        const entityMatch = content.match(/define\s+(root\s+)?view\s+entity\s+([A-Za-z0-9_]+)/i);
        if (entityMatch) {
            const entityName = entityMatch[2];
            if (!entityName.startsWith('ZI_') && !entityName.startsWith('ZC_') && !entityName.startsWith('ZR_')) {
                results.warnings.push(`[${fileName}] Naming Convention RAP: La entidad CDS '${entityName}' debería comenzar con 'ZI_' (Interface), 'ZC_' (Projection) o 'ZR_' (Root Base).`);
            }
        }

        // Convención de nombres de asociaciones: debe comenzar por guion bajo (_Item, _Header)
        const assocMatches = content.matchAll(/association\s+(?:\[[^\]]*\]\s+)?to\s+(?:parent\s+)?([A-Za-z0-9_\/]+)\s+as\s+([A-Za-z0-9_]+)/gi);
        for (const assoc of assocMatches) {
            const alias = assoc[2];
            if (!alias.startsWith('_')) {
                results.warnings.push(`[${fileName}] Naming Convention CDS: El alias de la asociación '${alias}' debería comenzar con '_' (ej. '_${alias}').`);
            }
        }
    }

    if (results.errors.length > 0) {
        results.passed = false;
    }

    return results;
}

if (require.main === module) {
    const targetFile = process.argv[2];
    if (!targetFile) {
        console.log("Uso: node check-abap-clean-code-quality.js <path-to-file.abap|cds>");
        process.exit(1);
    }
    const res = checkQuality(targetFile, true);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkQuality };
