/**
 * Script: test-abap-fiori.js
 * Propósito: Suite de pruebas unitarias automatizadas para los linters y checkers de ABAP y Fiori (16 Pruebas).
 */

const path = require('path');
const assert = require('assert');

const { checkQuality } = require('../../checkers/abap/check-abap-clean-code-quality.js');
const { checkRefactoring } = require('../../checkers/abap/check-abap-clean-code-refactoring.js');
const { checkRobustness } = require('../../checkers/abap/check-abap-robustness-nulls.js');
const { checkSecurity } = require('../../checkers/abap/check-abap-security.js');
const { checkPerformance } = require('../../checkers/abap/check-abap-performance.js');
const { checkSpecGovernance } = require('../../checkers/abap/check-abap-spec-governance.js');

const { checkFioriQuality } = require('../../checkers/fiori/check-fiori-clean-code-quality.js');
const { checkFioriSpecGovernance } = require('../../checkers/fiori/check-fiori-spec-governance.js');

const fixturesDir = path.join(__dirname, '..', 'fixtures');

console.log('========================================================================');
console.log(' 🧪 EJECUTANDO SUITE DE TESTS UNITARIOS (ABAP & SAP FIORI LINTERS - 16 TESTS)');
console.log('========================================================================\n');

let passedTests = 0;
let totalTests = 0;

function runTest(testName, fn) {
    totalTests++;
    try {
        fn();
        console.log(`  ✅ [PASS] ${testName}`);
        passedTests++;
    } catch (e) {
        console.error(`  ❌ [FAIL] ${testName}: ${e.message}`);
    }
}

// 1. ABAP Clean Code Quality / Refactoring / Robustness (Valid)
runTest('1. ABAP: Código válido debe pasar validaciones de calidad, refactoring y robustez', () => {
    const validAbap = path.join(fixturesDir, 'valid-clean-code.abap');
    const resQ = checkQuality(validAbap, true);
    const resR = checkRefactoring(validAbap, true);
    const resRob = checkRobustness(validAbap, true);

    assert.strictEqual(resQ.passed, true, `Quality falló: ${JSON.stringify(resQ.errors)}`);
    assert.strictEqual(resR.passed, true, `Refactoring falló: ${JSON.stringify(resR.errors)}`);
    assert.strictEqual(resRob.passed, true, `Robustness falló: ${JSON.stringify(resRob.errors)}`);
});

// 2. ABAP Clean Code (Invalid)
runTest('2. ABAP: Código inválido debe detectar Clean Core violations, comments, magic numbers y FS no asignados', () => {
    const invalidAbap = path.join(fixturesDir, 'invalid-clean-code.abap');
    const resQ = checkQuality(invalidAbap, true);
    const resR = checkRefactoring(invalidAbap, true);
    const resRob = checkRobustness(invalidAbap, true);

    assert.strictEqual(resQ.passed, false, 'Quality debería haber detectado errores');
    assert(resQ.errors.some(e => e.includes('Clean Core Violation') || e.includes('SUBMIT')), 'Debería detectar SUBMIT');
    assert(resQ.errors.some(e => e.includes('Comentario redundante')), 'Debería detectar comentarios redundantes');
    assert.strictEqual(resR.passed, false, 'Refactoring debería haber detectado errores');
    assert.strictEqual(resRob.passed, false, 'Robustness debería haber fallado');
});

// 3. ABAP Security (Valid)
runTest('3. ABAP Security: Código seguro con Authority-Check y OpenSQL debe pasar', () => {
    const validSec = path.join(fixturesDir, 'valid-security.abap');
    const res = checkSecurity(validSec, true);
    assert.strictEqual(res.passed, true, `Security válido falló: ${JSON.stringify(res.errors)}`);
});

// 4. ABAP Security (Invalid)
runTest('4. ABAP Security: Código con SQL Injection, INSERT REPORT y credenciales hardcodeadas debe fallar', () => {
    const invalidSec = path.join(fixturesDir, 'invalid-security.abap');
    const res = checkSecurity(invalidSec, true);
    assert.strictEqual(res.passed, false, 'Security inválido debería fallar');
    assert(res.errors.some(e => e.includes('Hardcoded Secret')), 'Debería detectar secreto hardcodeado');
    assert(res.errors.some(e => e.includes('SQL Injection Risk')), 'Debería detectar riesgo de SQL Injection');
    assert(res.errors.some(e => e.includes('Insecure Statement')), 'Debería detectar INSERT REPORT');
    assert(res.errors.some(e => e.includes('Missing Authorization')), 'Debería detectar falta de Authority-Check');
});

// 5. ABAP Performance (Valid)
runTest('5. ABAP Performance: Consultas optimizadas con guard FAE y proyección explícita deben pasar', () => {
    const validPerf = path.join(fixturesDir, 'valid-performance.abap');
    const res = checkPerformance(validPerf, true);
    assert.strictEqual(res.passed, true, `Performance válido falló: ${JSON.stringify(res.errors)}`);
});

// 6. ABAP Performance (Invalid)
runTest('6. ABAP Performance: SELECT *, SELECT en LOOP y FAE sin IS NOT INITIAL deben fallar', () => {
    const invalidPerf = path.join(fixturesDir, 'invalid-performance.abap');
    const res = checkPerformance(invalidPerf, true);
    assert.strictEqual(res.passed, false, 'Performance inválido debería fallar');
    assert(res.errors.some(e => e.includes('SELECT *')), 'Debería detectar SELECT *');
    assert(res.errors.some(e => e.includes('LOOP AT')), 'Debería detectar SELECT dentro de LOOP');
    assert(res.errors.some(e => e.includes('FOR ALL ENTRIES IN')), 'Debería detectar FAE sin IS NOT INITIAL');
});

// 7. CDS View (Valid)
runTest('7. CDS: Vista CDS válida con anotaciones @ObjectModel y asociación _Entity debe pasar', () => {
    const validCds = path.join(fixturesDir, 'valid-cds-view.cds');
    const res = checkQuality(validCds, true);
    assert.strictEqual(res.passed, true, `CDS válido falló: ${JSON.stringify(res.errors)}`);
});

// 8. CDS View (Invalid)
runTest('8. CDS: Vista CDS sin anotaciones y alias de asociación inválido debe detectar fallos', () => {
    const invalidCds = path.join(fixturesDir, 'invalid-cds-view.cds');
    const res = checkQuality(invalidCds, true);
    assert.strictEqual(res.passed, false, 'CDS sin anotaciones debería fallar');
    assert(res.errors.some(e => e.includes('Falta anotación CDS obligatoria')), 'Debería requerir anotaciones CDS');
    assert(res.warnings.some(w => w.includes('Naming Convention CDS')), 'Debería advertir asociación sin _');
});

// 9. ABAP Spec Governance (Valid)
runTest('9. Spec Governance: TS válida con Clean Core y ABAP Unit debe pasar', () => {
    const validSpec = path.join(fixturesDir, 'valid-ts-spec.md');
    const res = checkSpecGovernance(validSpec);
    assert.strictEqual(res.passed, true, `TS válida falló: ${JSON.stringify(res.errors)}`);
});

// 10. ABAP Spec Governance (Invalid)
runTest('10. Spec Governance: TS con tablas directas sin Released APIs debe fallar', () => {
    const invalidSpec = path.join(fixturesDir, 'invalid-ts-spec.md');
    const res = checkSpecGovernance(invalidSpec);
    assert.strictEqual(res.passed, false, 'TS inválida debería fallar');
    assert(res.errors.some(e => e.includes('Clean Core Violation') || e.includes('ABAP Unit')), 'Debería detectar Clean Core o falta de tests');
});

// 11. Fiori Spec Governance (Valid)
runTest('11. Fiori Spec Governance: Especificación UI con Fiori Elements y OData V4 debe pasar', () => {
    const validSpecContent = '# TS UI: List Report\nUso de Fiori Elements con List Report / Object Page.\nProtocolo OData V4.\nFloorplan y navegación Inbound definidos.';
    const res = checkFioriSpecGovernance(validSpecContent);
    assert.strictEqual(res.passed, true, `Fiori Spec válida falló: ${JSON.stringify(res.errors)}`);
});

// 12. Fiori Spec Governance (Invalid)
runTest('12. Fiori Spec Governance: Especificación UI Freestyle sin justificación debe fallar', () => {
    const invalidSpecContent = '# TS UI: Custom Screen\nDesarrollo de pantalla sin mención a FE ni justificación.';
    const res = checkFioriSpecGovernance(invalidSpecContent);
    assert.strictEqual(res.passed, false, 'Fiori Spec sin FE debe fallar');
    assert(res.errors.some(e => e.includes('Fiori Elements First Violation')), 'Debería exigir Fiori Elements First');
});

// 13. Fiori App (Valid)
runTest('13. Fiori: App Fiori completa con Component.js, manifest OData V4 e i18n debe pasar', () => {
    const validFioriApp = path.join(fixturesDir, 'fiori-valid');
    const res = checkFioriQuality(validFioriApp);
    assert.strictEqual(res.passed, true, `Fiori válida falló: ${JSON.stringify(res.errors)}`);
});

// 14. Fiori App (Invalid DOM / Sync / Hardcoded)
runTest('14. Fiori: App Fiori con DOM access, llamadas síncronas y texto hardcodeado debe fallar', () => {
    const invalidFioriApp = path.join(fixturesDir, 'fiori-invalid');
    const res = checkFioriQuality(invalidFioriApp);
    assert.strictEqual(res.passed, false, 'Fiori inválida debería fallar');
    assert(res.errors.some(e => e.includes('Manipulación directa del DOM')), 'Debería detectar DOM access');
    assert(res.errors.some(e => e.includes('Llamada síncrona bloqueante')), 'Debería detectar sync AJAX');
    assert(res.errors.some(e => e.includes('Texto literal hardcodeado')), 'Debería detectar texto sin i18n');
});

// 15. Fiori Component.js Structure (Invalid)
runTest('15. Fiori: Component.js sin herencia de UIComponent ni manifest metadata debe fallar', () => {
    const invalidFioriApp = path.join(fixturesDir, 'fiori-invalid');
    const res = checkFioriQuality(invalidFioriApp);
    assert(res.errors.some(e => e.includes('Estructura Component.js')), 'Debería exigir UIComponent');
    assert(res.errors.some(e => e.includes('Metadata Component.js')), 'Debería exigir manifest: "json"');
});

// 16. Fiori i18n Completeness Verification
runTest('16. Fiori: Verificación cruzada de claves i18n entre vistas XML y bundle de traducciones', () => {
    const validFioriApp = path.join(fixturesDir, 'fiori-valid');
    const res = checkFioriQuality(validFioriApp);
    const i18nErrors = res.errors.filter(e => e.includes('[i18n] Clave'));
    assert.strictEqual(i18nErrors.length, 0, 'No debería haber claves i18n faltantes en app válida');
});

console.log('\n========================================================================');
console.log(` 📊 RESULTADO: ${passedTests}/${totalTests} pruebas superadas.`);
console.log('========================================================================\n');

if (passedTests === totalTests) {
    process.exit(0);
} else {
    process.exit(1);
}
