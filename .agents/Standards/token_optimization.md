# OPTIMIZACIÓN DE RECURSOS (TOKEN SAVING)

> Extraído de `Rules/constitution.md` §7.
> Este fichero es la referencia operativa completa para la eficiencia de tokens y recursos en las interacciones de los agentes.

---

## 1. PRINCIPIOS GENERALES
Para garantizar la eficiencia operativa y reducir costes de contexto:
- **Modularización de Entregables:** Los documentos extensos (FS, BPD, Test Plan) **NUNCA** se generarán o leerán completos en un solo turno. El agente debe proponer un índice y desarrollar/revisar cada sección de forma independiente.
- **Comunicación Directa (No Fillers):** Se prohíben introducciones, cierres o frases de cortesía redundantes. El output debe saltar directamente al contenido técnico solicitado.
- **Densidad de Información:** Se priorizará el uso de tablas Markdown para datos estructurados en lugar de listas extensas.
- **Referenciación No-Redundante:** Si la información ya está documentada en un archivo adyacente, el agente debe enlazarlo (`[Referencia](...)`) en lugar de duplicar el texto.
- **Edición Unidireccional:** Se debe priorizar el uso de herramientas de reemplazo parcial (`replace_file_content`) sobre la reescritura total de archivos.
- **Modo Lean:** Cualquier información que no aporte valor técnico, metodológico o de gestión debe ser omitida.

---

## 2. OPTIMIZACIÓN DE CONSULTAS MCP (MCP Token Efficiency)
Las consultas a servidores MCP (`sap-docs-hosted`, `sap-ui5`, `abap-mcp-hosted`, etc.) son un consumidor significativo de tokens. Todos los agentes DEBEN aplicar las siguientes directrices al invocar herramientas MCP:
- **Límite de Resultados (`k` / `limit`):** Toda búsqueda en `sap-docs-hosted:search` debe usar `k=10` como valor por defecto (en lugar de 50). Solo se ampliará a 20-30 si los primeros 10 resultados no contienen la respuesta. Para `sap_search_objects`, usar `limit=10`.
- **Exclusión de Ejemplos en Consultas Conceptuales (`includeSamples`):** Si la consulta del usuario es conceptual, de configuración SPRO o de arquitectura de negocio (no requiere código fuente), el agente DEBE usar `includeSamples=false` para evitar la inyección masiva de repositorios de ejemplo y cheat-sheets.
- **Prohibición de Fetch Ciego:** El agente **NO debe ejecutar** `sap-docs-hosted:fetch` si el campo `snippet` devuelto en la búsqueda ya contiene la información solicitada (sintaxis, parámetros, descripción). El `fetch` completo se reserva estrictamente para cuando se requiera estudiar un manual de configuración completo, un ejemplo extenso o código muy complejo.
- **Selectividad en Discovery Center:** Al consultar `sap_discovery_center_service`, el agente DEBE desactivar los payloads que no necesita: usar `include_roadmap=false` si solo se requiere pricing, y `include_pricing=false` si solo se requiere el roadmap o las features del servicio.

---

## 3. EXCLUSIÓN DE CONTENIDO PESADO (.antigravityignore)
Para evitar que el indexador del sistema de IA y las búsquedas globales (`grep_search`) procesen archivos binarios y documentos redundantes de forma innecesaria:
- **Ignorado Activo obligatorio**: Se mantendrá configurado el archivo raíz [`.antigravityignore`](.antigravityignore) para excluir de las búsquedas:
  - Todo el contenido de las carpetas de históricos `**/99_Archive/`.
  - Archivos de versiones obsoletas (`*_vOLD*`, `.resolved.*`).
  - Archivos binarios generados (`.docx`, `.xlsx`, `.pptx`, `.pdf`, `.zip`).
- **Búsqueda Enfocada**: Los agentes nunca buscarán texto dentro de archivos binarios; la fuente de verdad siempre reside en los archivos Markdown (`.md`).
