# SKILL: ABAP CLOUD & RAP (RESTful ABAP Programming Model)

## CONTEXT
Referencia técnica obligatoria para todo desarrollo on-stack en S/4HANA Cloud y BTP ABAP Environment. El SAP Backend Developer DEBE consultar este skill antes de cada tarea de construcción.

---

## 1. ARQUITECTURA RAP — CAPAS OBLIGATORIAS

Todo Business Object (BO) RAP sigue esta estructura de 4 capas. Nunca saltes una capa:

```
[CDS Data Model] → [Behavior Definition] → [Service Definition] → [Service Binding]
     ZI_*                BDEF                    ZSRV_*               ZSRVB_*
```

### Patrones de implementación
| Patrón | Cuándo usarlo | Ejemplo |
|--------|---------------|---------|
| **Managed** | CRUD estándar sobre tablas custom (Z*). El framework gestiona el ciclo de vida. | Tablas de configuración, maestros propios |
| **Unmanaged** | Cuando necesitas control total del save sequence o wrappeas BAPIs/FMs existentes. | Wrapping de BAPI_SALESORDER_CREATE |
| **Managed + Unmanaged Save** | CRUD managed pero con lógica custom en el guardado. | Validaciones complejas pre-save |
| **Abstract Entity** | Sin persistencia. Para definir parámetros de acciones o entidades calculadas. | Parámetros de acción "Approve" |

### Naming Conventions RAP
- Data Definition (Interface): `ZI_<Entidad>`
- Data Definition (Consumption/Projection): `ZC_<Entidad>`
- Behavior Definition: Mismo nombre que el CDS root
- Service Definition: `ZSRV_<Nombre>`
- Service Binding: `ZSRVB_<Nombre>_<Protocolo>` (ej. `ZSRVB_ORDER_O4` para OData V4)

---

## 2. CDS MODELING — REGLAS

- Annotations semánticas obligatorias: `@EndUserText.label`, `@ObjectModel.semanticKey`.
- Usar `@AccessControl.authorizationCheck: #CHECK` en toda vista con datos sensibles.
- Favorecer composiciones (`composition [0..*] of`) sobre asociaciones sueltas para jerarquías padre-hijo.
- VDM Layering: Interface Views (`I_`) consumen las `ZI_`, nunca al revés.

---

## 3. HERRAMIENTAS MCP OBLIGATORIAS

Antes de escribir cualquier código ABAP, el agente DEBE ejecutar:

| Herramienta MCP | Cuándo | Por qué |
|-----------------|--------|---------|
| `abap-mcp-hosted:sap_search_objects` | Antes de crear un objeto Z* | Verificar que no existe ya una API estándar liberada |
| `abap-mcp-hosted:sap_get_object_details` | Al referenciar una clase/tabla SAP | Verificar estado de release y Clean Core level (A/B/C/D) |
| `abap-mcp-hosted:abap_lint` | Después de escribir código | Validar sintaxis, Cloud-readiness y best practices |
| `abap-mcp-hosted:search` | Al necesitar referencia de sintaxis | Buscar documentación oficial de statements |
| `abap-mcp-hosted:abap_feature_matrix` | Si hay duda sobre compatibilidad de versión | Verificar disponibilidad del feature en la release target |

---

## 4. ANTI-PATRONES (PROHIBIDO)

- ❌ `SELECT ... INTO TABLE ... FROM <tabla>` sin CDS (SQL clásico directo a tabla).
- ❌ `TABLES`, `RANGES`, `FIELD-SYMBOLS` sin declaración inline.
- ❌ Implicit Enhancements en código estándar.
- ❌ Llamadas directas a BAPIs sin wrapper RAP (unmanaged BO).
- ❌ Crear objetos Z* sin haber verificado primero vía MCP que no existe API estándar.
