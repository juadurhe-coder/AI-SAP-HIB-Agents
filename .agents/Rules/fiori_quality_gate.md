# REGLA OBLIGATORIA: Quality Gate para Apps SAP Fiori / SAPUI5

> **Ámbito:** Esta regla se aplica a TODAS las apps Fiori del workspace que contengan `manifest.json` + `ui5.yaml` (o `ui5-mock.yaml`).  
> **Nivel:** BLOQUEANTE — El agente NO puede declarar una entrega como completada si existen errores de severidad 2 (error) en cualquiera de los controles.

---

## 1. CUÁNDO SE ACTIVA

Esta regla se activa **siempre que el agente**:
- Cree una nueva app Fiori/SAPUI5 desde cero.
- Modifique ficheros de una app Fiori existente (vistas XML, controladores JS, manifest.json, index.html, Component.js, css, i18n).
- Corrija errores reportados por el usuario en una app Fiori.

El Quality Gate se ejecuta **EN LA FASE FINAL**, justo antes de declarar la entrega al usuario. Si falla, se corrige y se vuelve a ejecutar hasta que pase limpio.

---

## 2. CHECKLIST OBLIGATORIO (5 CONTROLES)

El agente DEBE ejecutar los siguientes controles en este orden:

### 2.1 `get_project_info` (MCP: sap-ui5)
- **Propósito:** Verificar que la estructura del proyecto es correcta (webapp/, manifest.json, Component.js, i18n/).
- **Bloqueo:** Si la estructura es inválida, corregir antes de continuar.

### 2.2 `run_manifest_validation` (MCP: sap-ui5)
- **Propósito:** Validar la versión del manifest, rutas de routing, dataSources, configuración i18n y minUI5Version.
- **Parámetro:** `manifestPath` = ruta absoluta al `webapp/manifest.json`.
- **Bloqueo:** Errores de severidad 2 bloquean la entrega.

### 2.3 `run_ui5_linter` (MCP: sap-ui5)
- **Propósito:** Detectar imports AMD rotos, APIs deprecadas, controles inexistentes, errores de parsing XML, atributos bootstrap obsoletos.
- **Parámetro:** `projectDir` = ruta absoluta al directorio raíz del proyecto Fiori (donde está `package.json`).
- **Bloqueo:** Errores de severidad 2 bloquean la entrega. Warnings de severidad 1 se reportan pero NO bloquean.

### 2.4 Build de verificación
- **Propósito:** Confirmar que el bundle de producción se genera sin errores.
- **Comando:** `npx ui5 build` o `npm run build` (según configuración del proyecto).
- **Bloqueo:** Si el build falla, corregir antes de entregar.

### 2.5 Verificación visual en navegador
- **Propósito:** Abrir la app en el navegador local y confirmar que renderiza sin errores de consola (404, ModuleError, script load error, etc.).
- **Método:** Usar `browser_subagent` para navegar a la URL local (ej: `http://localhost:8082/index.html`) y capturar screenshot + estado de consola.
- **Bloqueo:** Si hay errores de consola JavaScript, corregir antes de entregar.

---

## 3. FORMATO DE REPORTE

Al entregar la app, el agente DEBE incluir al final de su respuesta una sección con el siguiente formato:

```
### 🛡️ Quality Gate Fiori

| Control                  | Estado | Detalle                        |
|--------------------------|--------|--------------------------------|
| Estructura del Proyecto  | ✅/❌  | webapp/, manifest.json, etc.   |
| Manifest Validation      | ✅/❌  | Versión, routing, dataSources  |
| UI5 Linter               | ✅/❌  | X errors, Y warnings           |
| Build                    | ✅/❌  | Bundle generado correctamente  |
| Verificación en Navegador| ✅/❌  | Sin errores de consola         |
```

- Si TODOS los controles pasan → el agente puede declarar la entrega como **COMPLETADA**.
- Si algún control de severidad 2 falla → el agente DEBE corregir y re-ejecutar el ciclo completo hasta que pase.

---

## 4. MATRIZ DE DECISIÓN ARQUITECTÓNICA FIORI

Antes de iniciar cualquier desarrollo Fiori, el agente DEBE seleccionar el patrón arquitectónico adecuado:

| Criterio | Fiori Elements Floorplan (`sap.fe.templates.ListReport`) | Fiori Freestyle con Design System (`sap.f.DynamicPage`) |
| :--- | :--- | :--- |
| **Caso de Uso Óptimo** | Consultas estándar, CRUD directo, reportes analíticos gobernados 100% por anotaciones CDS y OData V4 en un entorno con Launchpad productivo. | Pantallas de cálculo interactivo, simulaciones en vivo en cliente (márgenes, conversiones FX), tarjetas KPI visuales en cabecera y modales de auditoría complejos. |
| **Vistas XML** | Cero vistas XML custom (todo autogenerado por metadatos). | Vistas XML declarativas (`Main.view.xml`, fragmentos modales) usando controles oficiales de SAPUI5. |
| **Arranque en Local** | Requiere Sandbox FLP completo con servicios UShell (`NavigationService`, `ShellUIService`). | Inicialización declarativa estándar limpia mediante `module:sap/ui/core/ComponentSupport`. |

---

## 5. ERRORES COMUNES A PREVENIR

Esta sección documenta errores recurrentes detectados para que el agente los evite proactivamente:

| Error | Causa | Prevención |
|-------|-------|------------|
| `sap/core/Item` → 404 | Namespace incorrecto en import AMD | Usar siempre `sap/ui/core/Item` |
| `<Badge>` en XML → control inexistente | `sap.m.Badge` no existe como control standalone | Usar `<ObjectStatus>` u `<ObjectNumber>` |
| `type="Positive"` / `type="Negative"` en `<Button>` | `Positive` y `Negative` no existen en `sap.m.ButtonType` | Usar `type="Accept"` (verde), `type="Reject"` (rojo), `type="Emphasized"` (azul) |
| `The specified value "10,0" cannot be parsed` | `<Input type="Number">` rechaza comas decimales en navegador | Usar `<Input type="Text" textAlign="End">` con formateador `sap.ui.model.type.Float` |
| `tableSettings` desconocido en Fiori Elements | Declarado en la raíz de `options.settings` | Declarar dentro de `options.settings.controlConfiguration["@com.sap.vocabularies.UI.v1.LineItem"]` |
| `TypeError: Cannot read properties of undefined (reading 'concat')` en flex | `changes-bundle.json` declarado como array `[]` | Estructurar siempre como objeto `{ "changes": [], "compVariants": [], "variants": [] }` |
| `TypeError: storeInnerAppStateAsync is not a function` | Ejecución de `sap.fe` sin servicios FLP | Usar `ComponentSupport` con vistas Freestyle o inicializar stubs de UShell en `init.js` |
| Expression bindings con arrow functions | El parser XML de UI5 no soporta ES6 arrow functions | Calcular valores en el controlador y bindear a propiedades simples del modelo |
| `data-sap-ui-resourceroots` → deprecado | Spelling antiguo del atributo bootstrap | Usar `data-sap-ui-resource-roots` (con guiones) |
| `data-sap-ui-oninit` → deprecado | Spelling antiguo | Usar `data-sap-ui-on-init` |
| `data-sap-ui-compatversion` → deprecado | Spelling antiguo | Usar `data-sap-ui-compat-version` |
| `data-sap-ui-frameoptions` → deprecado | Spelling antiguo | Usar `data-sap-ui-frame-options` |
| `_version: "1.40.0"` en manifest.json | Versión de manifest no soportada | Usar `"2.0.0"` o superior |
| `i18n_es.properties` 404 / `i18n_en.properties` 404 | manifest.json declara `supportedLocales: ["", "en", "es"]` pero los ficheros `i18n_en.properties` / `i18n_es.properties` no existen | Solo declarar locales en `supportedLocales` para los que existan ficheros. Si solo hay `i18n.properties` (default), usar `supportedLocales: [""]` |
| `fallback locale 'en' is not contained in supportedLocales` | Discrepancia entre `sap.app.i18n` y `sap.ui5.models.i18n`: una declara locales y la otra no | Sincronizar SIEMPRE `supportedLocales` y `fallbackLocale` en AMBAS secciones del manifest (`sap.app.i18n` y `sap.ui5.models.i18n.settings`) |
| `TypeError: Cannot read properties of undefined (reading 'getProperty')` en onInit | En routing async, `onInit()` se ejecuta ANTES de que el modelo del Component se propague a la vista. `this.getView().getModel()` devuelve `undefined` | NUNCA acceder al modelo directamente en `onInit()`. Usar `onBeforeRendering()` con guard, o `this.getOwnerComponent().getModel()`, o diferir con `setTimeout` |
| `Error: "Critical" is of type string, expected sap.ui.core.ValueState for property "state"` | En `ProgressIndicator` y controles UI5, los valores válidos de `ValueState` son: `None`, `Information`, `Success`, `Warning`, `Error`. `"Critical"` no existe en UI5 | Usar siempre los valores estándar de `sap.ui.core.ValueState`: `"Warning"` (en lugar de `"Critical"`), `"Error"`, `"Success"`, `"Information"` o `"None"` |
| `Assertion failed: ManagedObject.apply: encountered unknown setting 'class' for class 'sap.m.X'` | En instanciación programática en JS (`new VBox({ class: "..." })`), `class` no es una propiedad ni agregación de los controles SAPUI5 | NUNCA pasar `class: "..."` en el constructor de objetos UI5. Usar SIEMPRE el método `.addStyleClass("...")` |
| `XML node: '<f:subHeading>': Cannot add direct child without default aggregation defined for control sap.f.DynamicPageTitle` | `DynamicPageTitle` no posee agregación `subHeading` (solo `heading`, `actions`, `content`, `expandedContent`, `snappedContent`) | Agrupar título y subtítulo dentro de `<f:heading><VBox><Title .../><Text .../></VBox></f:heading>` |
| `Assertion failed: could not find any translatable text for key 'appDescription'` | `manifest.json` contiene `"description": "{{appDescription}}"` pero la clave `appDescription` no está definida en `i18n.properties` | Definir siempre `appTitle` y `appDescription` en `i18n.properties` e `i18n_es.properties` para satisfacer el descriptor del manifest |
| `TypeError: oBundle.getText is not a function` | Con `async: true` en `ResourceModel`, `oModel.getResourceBundle()` devuelve una Promise o el bundle aún no resuelto en ciclos tempranos | Validar siempre `if (oBundle && typeof oBundle.getText === "function")` antes de llamar a `oBundle.getText(sKey)`, con fallback devolviendo `sKey` |

---

## 6. EXCEPCIONES ACEPTADAS (NO BLOQUEAN)

Las siguientes advertencias del UI5 Linter están documentadas como **excepciones aceptadas** que NO bloquean la entrega:

| Regla del Linter | Severidad | Motivo de la Excepción |
|------------------|-----------|------------------------|
| `no-outdated-manifest-version` (quiere `_version: "2.0.0"`) | 2 | El sistema destino es SAP Solution Manager 7.2 (NW 7.50+) que usa manifest v1.x. Se mantiene `_version: "1.40.0"` por compatibilidad. |
| `no-legacy-ui5-version-in-manifest` (quiere `minUI5Version: "1.136.0"`) | 2 | SolMan 7.2 soporta típicamente SAPUI5 1.108–1.120. Se mantiene `minUI5Version: "1.108.0"` o `"1.120.0"` para compatibilidad con el Gateway del cliente. |

> **Regla:** Si el único hallazgo del linter es una de estas excepciones documentadas, la entrega se considera **APROBADA**.

---

## 6. INTEGRACIÓN CON DELIVERY MANAGER

El resultado del Quality Gate Fiori se considera un **entregable QA** del PMO Delivery Manager (`pmo_delivery_manager.md`). Si el proyecto tiene un Quality Gate Matrix activo, el pase del UI5 Linter + Build debe registrarse como evidencia en la puerta de calidad correspondiente (QG3: Desarrollo Completado / QG4: Test Aceptación).
