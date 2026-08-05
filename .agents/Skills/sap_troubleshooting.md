# SKILL: SAP TROUBLESHOOTING & DEBUGGING

## CONTEXT
Framework estructurado para diagnosticar y resolver problemas técnicos y funcionales en SAP S/4HANA. Aplicable cuando el usuario reporta un error, comportamiento inesperado o necesita depurar configuración SPRO, BAPIs, MRP, pricing u otros procesos.

---

## 1. FRAMEWORK DE DIAGNÓSTICO (4 PASOS)

### Paso 1: Recopilar Síntomas
Antes de proponer soluciones, recopilar:

| Dato | Ejemplo |
|------|---------|
| **Transacción/App** | VK11, MD04, BAPI_SALESORDER_CREATE |
| **Mensaje de error** | Texto completo del mensaje (ej. "Material XXX not available in plant YYY") |
| **Número de mensaje** | Clase + Número (ej. M7 156, VK 023) |
| **Pasos para reproducir** | "Crear pedido con tipo ZOR, asignar material X..." |
| **¿Funciona en otra variante?** | "Con tipo OR estándar sí funciona" |
| **¿Cuándo empezó?** | "Desde el transporte del viernes" |

### Paso 2: Buscar en Documentación y Comunidad
Ejecutar búsquedas en este orden:

```
1. abap-mcp-hosted:search(query="<mensaje de error o síntoma>")
2. abap-mcp-hosted:sap_community_search(query="<mensaje de error exacto>")
3. sap-docs-hosted:search(query="<transacción/objeto + comportamiento>")
```

### Paso 3: Analizar Configuración
Si el problema parece de config (SPRO), verificar:
- ¿El objeto tiene la configuración esperada? (Tipo de documento, grupo de cuentas, secuencia de acceso...)
- ¿Hay dependencias no configuradas? (Ej. esquema de pricing asignado, pero condición no mantenida)
- ¿El transporte movió la config? (Comparar entre mandantes si es posible)

### Paso 4: Proponer Solución
Articular la solución con:
1. **Causa raíz** identificada (no síntoma, sino por qué ocurre).
2. **Solución** con pasos exactos de SPRO/código.
3. **Verificación** de que la solución funciona.
4. **Prevención** para que no vuelva a ocurrir.

---

## 2. PATRONES COMUNES DE ERROR

### Pricing / Condiciones
| Síntoma | Causa Probable | Dónde Mirar |
|---------|---------------|-------------|
| Condición no se determina | Access Sequence incompleta o Key Combination mal mantenida | VK13, V/06, esquema de pricing |
| Precio = 0 en pedido | Registro de condición expirado o grupo de precios no asignado | VK13 (validez), VKM3 |
| BAPI no aplica pricing | Falta flag en BAPISDCOND o LOGIC_SWITCH | Parámetros de la BAPI, nota SAP |

### MRP / Disponibilidad
| Síntoma | Causa Probable | Dónde Mirar |
|---------|---------------|-------------|
| Material no aparece en MD04 | Tipo MRP incorrecto o centro no asignado | MM02 → MRP1, config de centro |
| Propuestas de compra no se generan | Umbral de reorder point no alcanzado o MRP no ejecutado | MD02, MM02 → MRP1 |
| Stock disponible no coincide | Stocks en transferencia, calidad o bloqueados | MMBE, MB52 |

### Sales Order / Delivery
| Síntoma | Causa Probable | Dónde Mirar |
|---------|---------------|-------------|
| Pedido no se graba | Datos obligatorios incompletos o partner functions | VA01 (log de mensajes) |
| Entrega no se crea | ATP falla o ruta de envío no determinada | VL01N, config de rutas |
| Factura bloqueada | Discrepancia de precios o entrega incompleta | VFX3, VKOA |

---

## 3. HERRAMIENTAS DE ESCALACIÓN

Si el diagnóstico no identifica la causa raíz con las búsquedas anteriores:

1. **Buscar OSS Notes:** Usar `sap-docs-hosted:sap_community_search` con el número de mensaje exacto.
2. **Feature Matrix:** Verificar si el behavior esperado está disponible en la release del cliente con `abap-mcp-hosted:abap_feature_matrix`.
3. **API Release State:** Si se sospecha de un objeto deprecado, verificar con `abap-mcp-hosted:sap_get_object_details`.

---

## 4. FORMATO DE RESPUESTA DE TROUBLESHOOTING

```markdown
> TL;DR: [Causa raíz en 1 línea] → [Solución en 1 línea]

## Diagnóstico
- **Síntoma reportado:** [...]
- **Causa raíz identificada:** [...]
- **Fuente:** [Enlace a nota SAP / documentación / post de comunidad]

## Solución
1. [Paso 1]
2. [Paso 2]
3. [Paso de verificación]

## Prevención
- [Recomendación para evitar recurrencia]
```
