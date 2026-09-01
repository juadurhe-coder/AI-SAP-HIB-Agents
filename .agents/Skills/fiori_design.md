# SKILL: FIORI DESIGN SYSTEM & UX

## PRINCIPLES
- **Consistency**: Usar Fiori Elements estándar siempre que sea posible. Solo recurrir a Freestyle SAPUI5 cuando Fiori Elements no cubra el caso.
- **Responsive**: Todo layout debe funcionar en phone, tablet y desktop.
- **Simplicity**: Mostrar solo lo necesario (Progressive Disclosure). Interfaces sobrecargadas = rechazo.

---

## 1. FIORI ELEMENTS FLOORPLANS — CUÁNDO USAR CADA UNO

| Floorplan | Caso de Uso | Ejemplo |
|-----------|-------------|---------|
| **List Report + Object Page** | CRUD masivo con filtros y detalle por ítem | Gestión de pedidos, materiales |
| **Analytical List Page (ALP)** | Reporting interactivo con KPIs y gráficos dinámicos | Dashboard de rebates, P&L por cliente |
| **Worklist** | Lista simple de tareas pendientes sin filtros complejos | Aprobación de solicitudes |
| **Overview Page (OVP)** | Vista ejecutiva con cards heterogéneas | Dashboard de manager |
| **Form Entry Object Page** | Creación/edición directa de registros complejos | Alta de contrato, configuración de pricing |

### Regla de Decisión
```
¿Necesita gráficos/KPIs? → ALP
¿Es CRUD con filtros?    → List Report + Object Page
¿Es una lista de tareas? → Worklist
¿Es un dashboard CxO?    → Overview Page
¿Nada de lo anterior?    → Freestyle SAPUI5 (último recurso)
```

---

## 2. PATRÓN FREESTYLE AVANZADO: `sap.f.DynamicPage` CON KPIS Y CÁLCULO EN VIVO

Cuando una aplicación requiera interactividad no cubierta por Floorplans estándar (como simulaciones matemáticas cliente, tarjetas KPI visuales en cabecera y modales de auditoría de fórmulas):

```xml
<f:DynamicPage id="dynamicPage" headerExpanded="true" fitContent="true" showFooter="true">
    <f:title>
        <f:DynamicPageTitle>
            <f:heading>
                <HBox alignItems="Center">
                    <Title text="{i18n>pageTitle}" level="H2"/>
                    <ObjectStatus text="{i18n>cleanCoreLevelA}" state="Success" inverted="true"/>
                </HBox>
            </f:heading>
            <f:actions>
                <Button text="{i18n>btnAction}" icon="sap-icon://simulate" type="Emphasized" press="onExecute"/>
                <Button text="{i18n>btnGenerate}" icon="sap-icon://accept" type="Accept" press="onGenerate"/>
            </f:actions>
        </f:DynamicPageTitle>
    </f:title>
    <f:header>
        <f:DynamicPageHeader pinnable="true">
            <!-- KPI Summary Cards + Filter Toolbar -->
        </f:DynamicPageHeader>
    </f:header>
    <f:content>
        <!-- Interactive Table with live calculation & audit dialog fragments -->
    </f:content>
</f:DynamicPage>
```

---

## 3. ANNOTATIONS CDS PARA UI — PATRÓN BÁSICO

Todo servicio OData V4 consumido por Fiori Elements DEBE tener estas annotations en la Consumption CDS View (`ZC_*`):

```cds
// Header info
@UI.headerInfo: { typeName: 'Order', typeNamePlural: 'Orders',
                   title.value: 'OrderID', description.value: 'CustomerName' }

// Facets (Object Page tabs)
@UI.facet: [{ id: 'General', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'General', position: 10 }]

// Line Item columns (List Report)
@UI.lineItem: [{ position: 10 }]   // → aparece como columna en la tabla

// Selection Fields (filtros)
@UI.selectionField: [{ position: 10 }]   // → aparece como filtro en la barra

// Field Group (Object Page fields)
@UI.fieldGroup: [{ qualifier: 'General', position: 10, label: 'Status' }]
```

---

## 4. HERRAMIENTAS MCP OBLIGATORIAS

| Herramienta | Cuándo | Por qué |
|-------------|--------|---------|
| `sap-ui5:get_guidelines` | Al inicio de cada tarea UI | Cargar las directrices oficiales actualizadas de Fiori |
| `sap-ui5:get_api_reference` | Al usar cualquier control SAPUI5 | Verificar API, propiedades y deprecaciones |
| `sap-ui5:run_ui5_linter` | Tras escribir/modificar código UI5 | Detectar uso de APIs deprecadas y errores |
| `sap-ui5:run_manifest_validation` | Tras modificar manifest.json | Validar configuración de la app |
| `sap-ui5:get_project_info` | Al abrir un proyecto existente | Entender framework, versión y estructura |

---

## 5. REGLAS TÉCNICAS Y CONTROL DE CONTROLES

- **OData V4** obligatorio en nuevos servicios de backend.
- **Enumeraciones Estrictas**: En botones `sap.m.Button`, usar `type="Accept"` (verde), `type="Reject"` (rojo), `type="Emphasized"` (azul). NUNCA usar `Positive`/`Negative`.
- **Formateo de Números en Inputs**: Usar `<Input type="Text" textAlign="End">` con formateador `sap.ui.model.type.Float` para evitar incompatibilidad con comas decimales (`10,0`) en navegadores locales.
- **Arranque Declarativo**: Usar `data-sap-ui-on-init="module:sap/ui/core/ComponentSupport"` y `<div data-sap-ui-component>` en `index.html`.
- **Flexibility Bundles**: Estructurar `changes-bundle.json` como objeto `{ "changes": [], "compVariants": [], "variants": [] }`, nunca como array plano `[]`.
- **CSS custom desacoplado**: Prohibición de atributos inline `style="..."` en controles XML. Usar clases en `webapp/css/style.css`.
- **Internacionalización (i18n)**: Todo texto visible DEBE residir en archivos `i18n.properties`, nunca hardcodeado.
