# SKILL: VALUE ENGINEERING & PRE-SALES TECHNIQUES

## CONTEXT
Técnicas de justificación de valor, estimación y presentación comercial para propuestas SAP. Utilizado por el Pre-Sales Solution Architect y el Functional Architect cuando trabajan en fase de Discovery o RFP/RFI.

---

## 1. FRAMEWORK DE JUSTIFICACIÓN DE VALOR

Toda propuesta debe articular el valor con este esquema de 4 capas:

| Capa | Pregunta que responde | Ejemplo |
|------|----------------------|---------|
| **Pain** | ¿Qué duele hoy? | "El cálculo de pricing manual consume 3 días/mes y genera errores del 3-5%" |
| **Impact** | ¿Cuánto cuesta no resolver? | "Pérdida estimada de €120K/año en margen por errores de pricing" |
| **Solution** | ¿Qué proponemos? | "App Fiori con cálculo automático de pricing vía RAP + BAPI wrapping" |
| **ROI** | ¿Cuánto gana el cliente? | "Reducción de 3 días a 2 horas. Payback en 4 meses." |

---

## 2. ESTIMACIÓN DE ESFUERZO

### Tabla de Referencia (Complejidad → Horas)
| Componente | Baja | Media | Alta | Muy Alta |
|-----------|------|-------|------|----------|
| CDS View + Service OData V4 | 8-16h | 16-32h | 32-48h | 48-80h |
| App Fiori Elements (LR+OP) | 16-24h | 24-40h | 40-64h | 64-100h |
| App Fiori Freestyle | 24-40h | 40-64h | 64-100h | 100-160h |
| RAP BO (managed) | 16-24h | 24-48h | 48-80h | 80-120h |
| RAP BO (unmanaged/BAPI wrap) | 24-40h | 40-64h | 64-100h | 100-160h |
| Integración BTP (CAP side-by-side) | 40-64h | 64-100h | 100-160h | 160-240h |
| Configuración SPRO | 4-8h | 8-16h | 16-32h | 32-48h |

### Regla del +20%
Siempre añadir un **20% de buffer** para testing, documentación y deployment. Nunca presentar estimaciones sin este margen.

---

## 3. ESTRUCTURA DE PROPUESTA EJECUTIVA

Usar siempre `Standards/proposal_template.md` como base, pero asegurarse de incluir:

1. **TL;DR ejecutivo** (3 líneas máximo): Dolor → Solución → Beneficio cuantificado.
2. **Diagrama de arquitectura** con Mermaid: Mínimo un diagrama que muestre componentes SAP involucrados.
3. **Timeline visual**: Fases con duración, no solo una lista de tareas.
4. **Mockup de UI**: Si hay componente Fiori, generar un prototipo HTML interactivo o captura.

---

## 4. HERRAMIENTAS MCP PARA DISCOVERY

| Herramienta | Uso en Pre-Venta |
|-------------|-----------------|
| `sap-docs-hosted:search` | Buscar Best Practices y documentación de procesos estándar para validar el approach |
| `sap-docs-hosted:sap_search_objects` | Identificar APIs liberadas disponibles para la solución propuesta |
| `abap-mcp-hosted:abap_feature_matrix` | Verificar que los features propuestos están disponibles en la release del cliente |
