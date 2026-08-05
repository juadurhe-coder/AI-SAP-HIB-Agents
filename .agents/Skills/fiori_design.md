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

## 2. ANNOTATIONS CDS PARA UI — PATRÓN BÁSICO

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

## 3. HERRAMIENTAS MCP OBLIGATORIAS

| Herramienta | Cuándo | Por qué |
|-------------|--------|---------|
| `sap-ui5:get_guidelines` | Al inicio de cada tarea UI | Cargar las directrices oficiales actualizadas de Fiori |
| `sap-ui5:get_api_reference` | Al usar cualquier control SAPUI5 | Verificar API, propiedades y deprecaciones |
| `sap-ui5:run_ui5_linter` | Tras escribir/modificar código UI5 | Detectar uso de APIs deprecadas y errores |
| `sap-ui5:run_manifest_validation` | Tras modificar manifest.json | Validar configuración de la app |
| `sap-ui5:get_project_info` | Al abrir un proyecto existente | Entender framework, versión y estructura |

---

## 4. REGLAS TÉCNICAS

- **OData V4** obligatorio. No usar V2 en proyectos nuevos.
- **CSS custom mínimo**: Preferir temas estándar (Horizon, Quartz). Solo CSS custom si es imprescindible para branding.
- **Internacionalización (i18n)**: Todo texto visible DEBE estar en archivos `i18n.properties`, nunca hardcodeado.
- **Flexibility**: Usar UI5 Flexibility / Adaptation Projects para cambios menores en apps estándar antes de crear apps custom.
