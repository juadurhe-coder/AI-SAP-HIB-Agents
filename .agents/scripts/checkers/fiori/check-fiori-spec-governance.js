/**
 * Script: check-fiori-spec-governance.js
 * Propósito: Validar especificaciones técnicas de Frontend/Fiori (TS UI) exigiendo
 *            'Fiori Elements First', anotaciones CDS UI, Floorplans y OData V4.
 */

const fs = require('fs');
const path = require('path');

function checkFioriSpecGovernance(specFilePath) {
    const results = {
        errors: [],
        warnings: [],
        passed: true
    };

    let content = '';
    let fileName = 'spec_ui.md';

    if (fs.existsSync(specFilePath)) {
        content = fs.readFileSync(specFilePath, 'utf-8');
        fileName = path.basename(specFilePath);
    } else if (typeof specFilePath === 'string' && specFilePath.includes('\n')) {
        content = specFilePath;
    } else {
        results.errors.push(`El archivo de especificación UI ${specFilePath} no existe.`);
        results.passed = false;
        return results;
    }

    // 1. Verificación de Fiori Elements First / Justificación Freestyle
    const mentionsFioriElements = /fiori elements|list report|object page|analytical list page|overview page|worklist/i.test(content);
    const mentionsFreestyleJustification = /justificaci[oó]n freestyle|freestyle rationale|custom ui5 app|por qu[eé] freestyle/i.test(content);

    if (!mentionsFioriElements && !mentionsFreestyleJustification) {
        results.errors.push(`[${fileName}] Fiori Elements First Violation: La especificación no indica el uso de Fiori Elements ni incluye justificación explícita para Freestyle.`);
    }

    // 2. Verificación de Floorplan y Navegación
    const hasFloorplanOrNavigation = /floorplan|routing|navegaci[oó]n|intent|semantic object|action|inbound navigation/i.test(content);
    if (!hasFloorplanOrNavigation) {
        results.warnings.push(`[${fileName}] Se recomienda detallar la estrategia de Floorplan y Navegación (Semantic Object / Action / Inbound) en la especificación UI.`);
    }

    // 3. Verificación de Anotaciones UI CDS (si es Fiori Elements)
    if (mentionsFioriElements) {
        const hasUiAnnotations = /@UI\.lineItem|@UI\.selectionField|@UI\.facet|@UI\.headerInfo|annotations\.xml|anotaciones cds/i.test(content);
        if (!hasUiAnnotations) {
            results.warnings.push(`[${fileName}] Para Fiori Elements, se recomienda detallar las anotaciones CDS UI (@UI.lineItem, @UI.selectionField, @UI.facet).`);
        }
    }

    // 4. Verificación de Protocolo OData V4
    const mentionsOData = /odata\s*v4|odata\s*4|odata\s*v2|odata\s*2/i.test(content);
    if (!mentionsOData) {
        results.warnings.push(`[${fileName}] Se recomienda explicitar el protocolo OData (requerido OData V4 para nuevos desarrollos).`);
    }

    if (results.errors.length > 0) {
        results.passed = false;
    }

    return results;
}

if (require.main === module) {
    const targetFile = process.argv[2];
    if (!targetFile) {
        console.log("Uso: node check-fiori-spec-governance.js <path-to-spec.md>");
        process.exit(1);
    }
    const res = checkFioriSpecGovernance(targetFile);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkFioriSpecGovernance };
