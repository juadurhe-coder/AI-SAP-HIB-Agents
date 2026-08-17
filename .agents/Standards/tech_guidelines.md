# DIRECTRICES TÉCNICAS (TECHNICAL GUIDELINES)

## 1. ENFOQUE "CLEAN CORE"
Todos los desarrollos técnicos, diseños y arquitecturas deben regirse por el principio estricto de Clean Core, salvaguardando la integridad del S/4HANA.
- Quedan estrictamente prohibidas las modificaciones directas a objetos estándar SAP o al core transaccional (Keep it Mod-Free).
- No se deben prescribir ampliaciones invasivas e implícitas (ej. Implicit Enhancements en código estándar) si existen BAdIs modernas u opciones side-by-side.

## 2. PRIORIDADES TECNOLÓGICAS
- SAP BTP (Business Technology Platform): Base indispensable para desarrollar extensiones complejas (side-by-side) e integraciones (Integration Suite).
- APIs Estándar: Priorizar en todo momento el uso de whitelisted APIs de SAP (REST/OData) para la comunicación transaccional hacia el backend.
- ABAP Cloud & RAP: Todos los nuevos desarrollos en el entorno on-Stack deben usar el modelo RAP (RESTful ABAP Programming Model) y el esquema ABAP Cloud. Se rechazarán outputs con legacy statements antiguos de ABAP clásico que no sean Cloud-ready.
- CDS Views: Uso primordial de Core Data Services (VDM - Virtual Data Model) para el modelado de datos y analíticas.

### 2.1 Estándar de Tooling y Dependencias Frontend Fiori (Modern UI5 Tooling)
Todo proyecto SAP Fiori / SAPUI5 generado o mantenido DEBE utilizar las versiones activas y estables del tooling oficial de SAP:
- `@ui5/cli`: Versión mínima obligatoria `^4.0.0` (prohibido `^3.x` o anterior).
- `@sap/ux-ui5-tooling`: Versión mínima recomendada `^1.30.0`.
- `@sap-ux/ui5-middleware-fe-mockserver`: Versión mínima `^2.0.0` para simulación OData V4 offline.
- **Validación Automática:** Todo proyecto Fiori debe ser auditado con `node .agents/scripts/checkers/fiori/check-fiori-clean-code-quality.js`, el cual valida automáticamente que no existan dependencias obsoletas en `package.json`.

### 2.2 Estándares de Vistas XML, Bootstrap HTML e i18n
1. **Controles Estándar en XML:** Prohibido el uso de etiquetas HTML no estándar como controles UI5 (ej. `<Badge>` en `sap.m` no existe; debe usarse `sap.m.ObjectStatus`, `sap.m.Title` o `sap.tnt.InfoLabel`).
2. **Bootstrap Asíncrono e `init.js`:** Cuando se active `data-sap-ui-async="true"` en `index.html`, está prohibido ejecutar scripts inline con `sap.ui.getCore().attachInit()` por riesgo de race conditions. Debe utilizarse `data-sap-ui-oninit="module:<namespace>/init"`. En `init.js` debe usarse siempre la API moderna no bloqueante `sap/ui/core/Component.create({ manifest: true, async: true })`.
3. **Desarrollo Local sin 404s de Preload:** Todo `index.html` de pruebas locales debe incluir `data-sap-ui-xx-componentpreload="off"` y `data-sap-ui-preload="async"`.
4. **Dimensionamiento del Viewport:** El contenedor raíz del ComponentContainer debe tener dimensiones explícitas (`height: calc(100vh - 44px)` o `100%`) para evitar el colapso a 0px de layouts responsivos como `sap.f.FlexibleColumnLayout`.
5. **Carga de Datos 100% Asíncrona:** Queda prohibido el uso de `loadData(..., false)` o `async: false` en llamadas AJAX y modelos JSON. El modelo `i18n` en `manifest.json` debe declarar obligatoriamente `"settings": { "async": true }` para prevenir peticiones XHR síncronas bloqueantes en el hilo principal.
6. **Accesibilidad WAI-ARIA y Campos Read-Only:** Todo control `<Label>` interactivo debe tener un atributo `labelFor` vinculado al ID de su campo de entrada. Para formularios o fichas de solo lectura (valores informativos o KPIs), deben usarse contenedores semánticos (`layout:Grid`, `VBox` con `<Title level="H6">` o `<Text>`) en lugar de etiquetas `<Label>` huérfanas en `SimpleForm`.
7. **Soporte Multilingüe e i18n:** `manifest.json` debe incluir siempre `""` (idioma raíz) y `"en"` (fallback oficial de SAPUI5) en `supportedLocales`.

## 3. CONVENCIONES DE NOMENCLATURA (NAMING CONVENTIONS)
Todo desarrollo customizado, modelado y configuración debe obedecer los namespaces designados para clientes:
- Utilizar prefijos `Z*` o `Y*` para objetos del diccionario de datos (DDIC), clases (`ZCL_*`, `ZCX_*`), programas, interfaces CDS (`ZI_*`, `ZC_*`), roles, etc.
