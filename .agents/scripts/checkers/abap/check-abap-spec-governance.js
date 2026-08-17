/**
 * Script: check-abap-spec-governance.js
 * Propósito: Validar especificaciones técnicas ABAP (TS) frente a requisitos de Clean Core,
 *            Arquitectura RAP, Reusabilidad y ABAP Unit.
 */

const fs = require('fs');
const path = require('path');

function checkSpecGovernance(specFilePath) {
    const results = {
        errors: [],
        warnings: [],
        passed: true
    };

    let content = '';
    let fileName = 'spec.md';

    if (fs.existsSync(specFilePath)) {
        content = fs.readFileSync(specFilePath, 'utf-8');
        fileName = path.basename(specFilePath);
    } else if (typeof specFilePath === 'string' && specFilePath.includes('\n')) {
        content = specFilePath;
    } else {
        results.errors.push(`El archivo de especificación ${specFilePath} no existe.`);
        results.passed = false;
        return results;
    }

    // 1. Verificación de Reusabilidad (Helpers / Utilities)
    const hasReusabilitySection = /reusab|helper|utility|clase gen[eé]rica|m[oó]dulo com[uú]n/i.test(content);
    if (!hasReusabilitySection) {
        results.warnings.push(`[${fileName}] Falta sección explícita de 'Componentes y Métodos Reutilizables/Helpers' en la especificación.`);
    }

    // 2. Verificación de Clean Core / Released APIs
    const hasNonReleasedTables = /\b(VBAK|VBAP|EKKO|EKPO|BSIS|BKPF|MARA|MARC)\b/i.test(content);
    if (hasNonReleasedTables) {
        // Si menciona tablas pero no menciona CDS Views ni Released APIs equivalentes
        const mentionsCdsReleased = /I_SalesOrder|I_PurchaseOrder|I_Product|I_JournalEntry|CDS|Released API|Whitelisted/i.test(content);
        if (!mentionsCdsReleased) {
            results.errors.push(`[${fileName}] Clean Core Violation: Se referencian tablas estándar directas sin especificar vistas CDS / Released APIs (ej. I_SalesOrder, I_PurchaseOrder).`);
        } else {
            results.warnings.push(`[${fileName}] Clean Core Note: Se mencionan tablas clásicas; asegúrese de que el consumo se realice mediante Released APIs / CDS VDM.`);
        }
    }

    // 3. Verificación de Pruebas Unitarias (ABAP Unit / Mocking)
    const hasUnitTestStrategy = /abap unit|pruebas unitarias|unit test|test double|mock/i.test(content);
    if (!hasUnitTestStrategy) {
        results.errors.push(`[${fileName}] Falta la definición de la estrategia de Pruebas Unitarias (ABAP Unit / Test Doubles / Mocking).`);
    }

    // 4. Verificación de Arquitectura RAP en desarrollos on-stack
    const isBackendSpec = /04_TS|backend|abap|rap|cds/i.test(fileName) || /abap cloud|rap|restful/i.test(content);
    if (isBackendSpec) {
        const hasRapLayers = /behavior definition|bdef|service definition|service binding|cds view|zi_|zc_/i.test(content);
        if (!hasRapLayers) {
            results.warnings.push(`[${fileName}] Se recomienda especificar la arquitectura RAP (CDS Interface ZI_, Projection ZC_, BDEF y Service Binding).`);
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
        console.log("Uso: node check-abap-spec-governance.js <path-to-spec.md>");
        process.exit(1);
    }
    const res = checkSpecGovernance(targetFile);
    console.log(JSON.stringify(res, null, 2));
    process.exit(res.passed ? 0 : 1);
}

module.exports = { checkSpecGovernance };
