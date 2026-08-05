# SKILL: SAP TESTING STANDARDS (QA)

## CONTEXT
Estándares de testing que todo Developer (Backend y Frontend) debe seguir. El PMO Reviewer verifica su cumplimiento en el Quality Gate.

---

## 1. BACKEND — ABAP UNIT (RAP)

### Cuándo es obligatorio
- Toda validación o determinación en un Behavior Pool.
- Toda acción custom (ej. "Approve", "Calculate Pricing").
- Toda lógica de negocio en clases auxiliares (helpers/utilities).

### Estructura de Test Class

```abap
CLASS ltc_order_validation DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.
  PRIVATE SECTION.
    METHODS:
      test_valid_order FOR TESTING,
      test_missing_customer FOR TESTING RAISING cx_static_check,
      setup.
    DATA: cut TYPE REF TO zcl_order_validation.  "Class Under Test
ENDCLASS.

CLASS ltc_order_validation IMPLEMENTATION.
  METHOD setup.
    " Arrange: Prepare test doubles / mock data
    cut = NEW zcl_order_validation( ).
  ENDMETHOD.
  METHOD test_valid_order.
    " Act
    DATA(result) = cut->validate( order_id = '100001' ).
    " Assert
    cl_abap_unit_assert=>assert_equals( act = result exp = abap_true ).
  ENDMETHOD.
  METHOD test_missing_customer.
    " Expect exception
    TRY.
        cut->validate( order_id = '' ).
        cl_abap_unit_assert=>fail( msg = 'Should have raised exception' ).
      CATCH zcx_validation_error.
        " Expected
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
```

### Validación vía MCP
Después de escribir tests, ejecutar `abap-mcp-hosted:abap_lint` sobre el código de test para verificar sintaxis y buenas prácticas.

---

## 2. BACKEND — SERVICE TESTING (OData V4)

- Verificar que el Service Binding responde correctamente con `$metadata`.
- Probar operaciones CRUD con datos de prueba antes de conectar frontend.
- Verificar Authorization checks (`@AccessControl`) con distintos roles.

---

## 3. FRONTEND — FIORI / UI5

### Mock Data (Siempre)
- Todo proyecto Fiori DEBE incluir un directorio `localService/` con:
  - `metadata.xml` (copia del $metadata del servicio OData)
  - `mockdata/` con archivos JSON por EntitySet

### OPA5 — Integration Tests (Para lógica custom compleja)
```javascript
opaTest("Should display the list of orders", function (Given, When, Then) {
    Given.iStartMyApp();
    When.onTheListPage.iSearchFor("Order");
    Then.onTheListPage.iSeeOrdersInTheList(5);
    Then.iTeardownMyApp();
});
```

### Cuándo es obligatorio OPA5
- Navegación custom entre vistas.
- Lógica en controllers que altera datos o estado.
- Flujos de edición multi-paso.

### Validación vía MCP
Ejecutar `sap-ui5:run_ui5_linter` tras modificaciones para detectar APIs deprecadas.

---

## 4. CHECKLIST DE QA (Para el PMO Reviewer)

| Check | Backend | Frontend |
|-------|---------|----------|
| Tests unitarios existen | ABAP Unit | QUnit (si hay lógica custom) |
| Tests de integración | OData CRUD verificado | OPA5 journeys |
| Mock data disponible | N/A | `localService/` con metadata + mockdata |
| Linting pasado | `abap_lint` sin errores | `ui5_linter` sin errores |
| Sin APIs deprecadas | Clean Core level A verificado | UI5 linter report limpio |
