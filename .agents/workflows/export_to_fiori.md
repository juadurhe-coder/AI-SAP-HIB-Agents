---
description: Convierte un mockup HTML o especificación funcional a una aplicación SAP Fiori completa, estandarizada y validada por Quality Gates
---

Este workflow se utiliza cuando el usuario solicita **convertir un mockup HTML/CSS/JS previo, prototipo visual o especificación técnica en una aplicación SAP Fiori real** (`sap.f.DynamicPage` o *Fiori Elements*).

---

### 🎯 Objetivo del Workflow
Garantizar que la aplicación resultante:
1. **Conserve el 100% de la riqueza visual y funcional del mockup** (tarjetas KPI, barras de filtros, semáforos, tablas de cálculo interactivo y modales de auditoría).
2. **Utilice arquitectura oficial de SAPUI5 / Fiori Design System** (Horizon theme, arranque declarativo con `ComponentSupport`, clases CSS desacopladas sin `style="..."` inline).
3. **Pase limpiamente los Quality Gates** (cero textos literales fuera de `i18n`, tipos de controles estrictos y cero errores en la consola DevTools).

---

### 🚀 Pipeline Estandarizado en 6 Pasos

#### Paso 1: Triaje de Arquitectura (Floorplan vs Freestyle)
Evalúa el caso de uso del mockup según la **Matriz de Decisión**:
* **Fiori Elements Floorplan (`sap.fe.templates.ListReport`):** Si la app es una consulta estándar o CRUD directo sobre backend OData V4 en Launchpad productivo.
* **Fiori Freestyle con `sap.f.DynamicPage` (Recomendado para mockups ricos):** Si la app incluye simulaciones matemáticas cliente en tiempo real (márgenes, cálculos FX), tarjetas KPI visuales en cabecera o modales con múltiples pestañas de auditoría.

---

#### Paso 2: Mapeo Riguroso de Elementos HTML a Controles Fiori Horizon
Aplica la siguiente tabla de equivalencias oficial para evitar tags HTML ad-hoc o propiedades no estándar:

| Elemento Mockup HTML | Control Estándar SAPUI5 | Configuración / Buenas Prácticas |
| :--- | :--- | :--- |
| **Contenedor Principal** | `<f:DynamicPage>` | `headerExpanded="true" fitContent="true" showFooter="true"` |
| **Cabecera & Badges** | `<f:DynamicPageTitle>` + `<ObjectStatus>` | Distintivo *Clean Core Level A* con `state="Success"` e `inverted="true"`. |
| **Tarjetas KPI** | `<HBox>` + `<VBox class="kpiCard">` | Clases `.kpiSuccess`, `.kpiWarning`, `.kpiError` en `style.css` y `<core:Icon>`. |
| **Barra de Filtros** | `<OverflowToolbar>` | `<SearchField>` + `<Select>` + `<Button icon="sap-icon://clear-filter">`. |
| **Tabla de Datos** | `<Table>` (`sap.m.Table`) | `sticky="ColumnHeaders,HeaderToolbar"`, `mode="MultiSelect"`. |
| **Semáforos de Estado** | `<ObjectStatus>` | `state="{pricing>statusState}" icon="{pricing>statusIcon}" inverted="true"`. |
| **Inputs Numéricos / Margen** | `<Input type="Text" textAlign="End">` | Binding con `sap.ui.model.type.Float` (evita warnings con comas en `type="Number"`). |
| **Botones de Acción Verde/Rojo** | `<Button>` | `type="Accept"` para verde; `type="Reject"` para rojo; `type="Emphasized"` para azul primario. |
| **Diálogos / Modales** | `<core:FragmentDefinition>` | Fragmentos XML (`LogDialog.fragment.xml`) cargados con `Fragment.load`. |

---

#### Paso 3: Extracción Exhaustiva de Textos a `i18n`
1. Prohibido incluir textos literales hardcodeados en vistas XML o controladores.
2. Generar todos los pares clave-valor tanto en `webapp/i18n/i18n.properties` (idioma base) como en `webapp/i18n/i18n_es.properties` (español).
3. Sincronizar las secciones `sap.app.i18n` y `sap.ui5.models.i18n` en `manifest.json`.

---

#### Paso 4: Modelado OData V4 y Generación de Mockdata
1. Crear el modelo de datos en `webapp/localService/mockdata/` con datos representativos y realistas.
2. Si la app incluye reglas de negocio (como matriz de márgenes o tablas de lookup), estructurar el JSON correspondiente (`defaults.json`).
3. Implementar la lógica de cálculo cliente interactiva en el controlador (`Main.controller.js`), actualizando los modelos JSON y contadores de KPI reactivamente.

---

#### Paso 5: Arranque Declarativo Estándar y Desacoplamiento UShell
1. Configurar `webapp/index.html` con la inicialización declarativa oficial:
   ```html
   <script
       id="sap-ui-bootstrap"
       src="https://ui5.sap.com/resources/sap-ui-core.js"
       data-sap-ui-theme="sap_horizon"
       data-sap-ui-resource-roots='{ "com.sap.app": "./" }'
       data-sap-ui-on-init="module:sap/ui/core/ComponentSupport"
       data-sap-ui-compat-version="edge"
       data-sap-ui-async="true"
       data-sap-ui-frame-options="trusted">
   </script>
   <div data-sap-ui-component data-name="com.sap.app" data-height="100%" id="content"></div>
   ```
2. Asegurar que `changes-bundle.json` tenga la estructura canónica `{ "changes": [], "compVariants": [], "variants": [] }`.

---

#### Paso 6: Verificación Automatizada del Quality Gate
Antes de declarar completada la conversión, ejecuta obligatoriamente los checkers:

```powershell
# 1. Auditoría de Código Limpio y Gobernanza Fiori
node .agents/scripts/checkers/fiori/check-fiori-clean-code-quality.js "<RUTA_APP_FIORI>"

# 2. Suite Completa de Tests de Regresión
node .agents/scripts/tests/linters/test-abap-fiori.js
```

Si el checker detecta cualquier error de severidad 2, corrígelo antes de entregar al usuario.
Una vez limpio, notifica al usuario indicando la URL local (`http://localhost:8080/index.html`) para su verificación visual.
