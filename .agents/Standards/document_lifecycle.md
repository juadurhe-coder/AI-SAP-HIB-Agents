# ESTRUCTURA, ORGANIZACIÓN Y CICLO DE VIDA DE DOCUMENTOS

> Extraído de `Rules/constitution.md` §5, §6, §8.
> Este fichero es la referencia operativa completa para la gestión de archivos, nomenclatura, versionado, idiomas y memoria persistente de proyecto bajo la estructura unificada de `Projects/`.

---

## 1. CREACIÓN DE PROYECTOS Y BORRADORES
Todo nuevo entregable, requerimiento inicial o propuesta **DEBE** crearse directamente en una subcarpeta dedicada dentro del directorio unificado raíz [Projects](Projects/), siguiendo el formato `Nombre_Proyecto` (o `INC-[Nº]` / `SR-[Nº]` para incidencias y service requests). 

Al inicializar esta carpeta, el agente **DEBE** crear de forma obligatoria los siguientes archivos de partida:
1. `00_Project_Memory.md` (como memoria a largo plazo y fuente persistente de la verdad, utilizando la plantilla `Standards/project_memory_template.md`).
2. `01_Proposal_[Nombre_Proyecto]_v1.0.md` (como propuesta formal de preventa/idea, utilizando la plantilla `Standards/proposal_template.md`).

## 2. CONTROL DE APROBACIÓN
Dado que la estructura está unificada en `Projects/` y no hay separación física de carpetas por estado de aprobación, el estado de avance y aprobación de cada propuesta frente al cliente se mantendrá documentado y actualizado en:
1. El archivo general de tareas **`Kanban.md`** en la raíz (bajo las etiquetas de fase como `{Design_Phase}`, `{UAT}`, etc.).
2. El archivo local **`00_Project_Memory.md`** en la sección de estado del proyecto.

## 3. NAMING CONVENTION & VERSIONADO (SAP ACTIVATE)
Los documentos dentro de cada carpeta de proyecto deben seguir el estándar de prefijo de trazabilidad y prefijo numérico correspondiente a su fase o tipo de documento, según el siguiente formato:

```
[[IDTrazabilidad]]_[PrefijoNumérico]_[TipoDocumento]_[NombreEntregable]_vX.Y.[ext]
```

Donde:
* **`[[IDTrazabilidad]]`**: Es el **número de ticket** (p. ej. `[76551]`, `[105295]`) o el **código de proyecto** (p. ej. `[PRJ-REB]`, `[PRJ-FRDD]`) entre corchetes. Si no se dispone de ticket o código de proyecto, se usará strictly el marcador con corchetes `[XXXXX]`.
* **`[PrefijoNumérico]`**: Prefijo de fase `00_` a `06_`.

Cualquier cambio mayor incrementa la versión decimal (v1.1) y los hitos clave la versión entera (v2.0).

### Tabla de Nomenclatura Estándar:
| Prefijo | Tipo de Documento / Rol | Descripción / Hito SAP Activate | Ejemplo |
| :---: | :--- | :--- | :--- |
| **`00_`** | **Project Memory / Readme** | Fichero general de contexto y memoria del proyecto. | `[XXXXX]_00_Project_Memory.md` |
| **`01_`** | **Proposal / Business Case** | Propuesta comercial, de valor o concepto inicial (Discover/Prepare). | `[76551]_01_Proposal_PriceReport_EN_v1.0.md` |
| **`02_`** | **Functional Specification (FS)** | Especificación funcional del consultor funcional (Explore). | `[105295]_02_FS_PreventZeroQty_ES_v1.0.md` |
| **`03_`** | **Technical Spec Backend (TS_BE)** | Especificación técnica backend para desarrollo ABAP/OData (Realize). | `[76551]_03_TS_Backend_PriceReport_EN_v1.0.md` |
| **`04_`** | **Technical Spec Frontend (TS_FE)** | Especificación técnica frontend para Fiori/UI5 (Realize). | `[PRJ-REB]_04_TS_Frontend_RebateOData_v1.0.md` |
| **`05_`** | **Test Script / QA** | Guía de pruebas unitarias, integradas y UAT (Verify). | `[PRJ-FRDD]_05_Test_Script_FlexibleDates_v1.0.md` |
| **`06_`** | **Cutover & Deploy** | Tareas de traspaso a producción y checklist de Go-Live (Deploy). | `[PRJ-IC-DROP]_06_Cutover_DropShipment_v1.0.md` |

## 4. IDENTIFICACIÓN DE TRAZABILIDAD (TICKET Y CÓDIGO DE PROYECTO)
Al iniciar la creación de cualquier propuesta o entregable, el agente **DEBE** solicitar el número de ticket (Jira, ServiceNow, etc.) o el código del proyecto (p. ej., `PRJ-REB`). Este ID es obligatorio para el nombrado de archivos y quedará registrado en el `[XXXXX]_00_Project_Memory.md`.

**Regla de Prefijo de Trazabilidad Obligatoria:** Todos los archivos creados deben llevar este identificador de trazabilidad entre corchetes como primer elemento en su nombre. Si un proyecto engloba múltiples tickets, se utilizará preferiblemente el código general de proyecto (ej. `[PRJ-IC-DROP]_06_Cutover_DropShipment_v1.0.md`). Si no se dispone de ticket o código de proyecto, se usará strictly el marcador `[XXXXX]`.

Si el nombre de la carpeta del proyecto está relacionado con un ticket específico, se utilizará preferiblemente el patrón `[IDProyecto]_NombreDescripcion` o `INC-[Nº]_[Nombre]` (ej. `ZSD_PRICE_REPORT_Modification_76551` o `Projects/INC-105295_Prevent_Zero_Qty/`).

## 5. SISTEMA DE ARCHIVO Y VERSIONADO
- Las versiones superadas, borradores iniciales o documentos rechazados deben moverse inmediatamente a una subcarpeta `99_Archive/` dentro de la carpeta del proyecto.
- **Procedimiento Obligatorio:** Al archivar un archivo (ej. `..._v1.0.md`), el agente debe crear la nueva copia de trabajo incrementando la versión en el nombre del archivo (ej. `..._v1.1.md`) y en su cabecera. Se prohíbe reutilizar la misma versión para contenidos distintos.
- **Excepción:** En refactorizaciones mayores o por solicitud del usuario, se permite mantener la versión previa en la raíz con el sufijo `_vOLD` temporalmente.
- **Archivado de Kanban**: Para evitar el crecimiento indefinido de [Kanban.md](Kanban.md) y optimizar el consumo de tokens en lecturas recurrentes (ej: durante el daily), las tareas de la sección `DONE` que tengan más de 15 días de antigüedad desde su finalización serán trasladadas periódicamente por el agente a un archivo de histórico de tareas completadas en [Projects/99_Archive/Kanban_Archive.md](Projects/99_Archive/Kanban_Archive.md).

## 6. HIGIENE DE ARCHIVOS Y DUPLICADOS
Se prohíbe la acumulación de archivos temporales, copias de seguridad automáticas (ej. `(1)`, `(2)`) o versiones duplicadas en las carpetas de trabajo. Si un agente detecta estos archivos, debe archivarlos (en `99_Archive/`) o eliminarlos de forma proactiva para evitar confusión.

## 7. REGLA DE MOCKUPS FIORI
Solo se generará un mockup de UI y se incluirá la sección correspondiente en la propuesta si el requerimiento implica explícitamente una interfaz de usuario (Fiori/UI5). Para propuestas puramente de backend o configuración, se debe omitir esta sección y no generar archivos HTML de mockup.

## 8. TRAZABILIDAD DE CAMBIOS ESTRUCTURALES
Cualquier cambio estructural o creación de carpetas debe ser comunicado explícitamente al usuario.

## 9. ⛔ GATE 0 — CHECKLIST OBLIGATORIO PRE-EDICIÓN DE ARCHIVOS VERSIONADOS
Antes de ejecutar CUALQUIER edición (`replace_file_content`, `multi_replace_file_content` o `write_to_file` con Overwrite) sobre un archivo que contenga una versión en su nombre (ej. `_v1.0`, `_v3.0`), el agente **DEBE ejecutar obligatoriamente** los siguientes pasos en este orden exacto:
1. **Crear `99_Archive/`** en la carpeta del documento si no existe.
2. **Mover el archivo actual** (`.md` y `.docx` si existe) a `99_Archive/` tal como está, sin modificar su contenido.
3. **Crear la nueva copia de trabajo** con la versión incrementada en el nombre del archivo (ej. `_v4.0` → `_v4.1`) y actualizar la cabecera interna (`Version:`) del documento.
4. **Limpiar la carpeta raíz:** Inspeccionar y mover a `99_Archive/` cualquier archivo temporal, duplicado o versión anterior que detecte (ej. `_vOLD`, `.resolved`, `- copia`).
5. **Solo entonces** aplicar la edición de contenido solicitada sobre el nuevo archivo de trabajo.

**Violación = Fallo crítico.** Si el agente edita un archivo versionado in-place sin completar estos 5 pasos (a menos que aplique la excepción abajo detallada), se considera un incumplimiento grave de la constitución del proyecto.

**Excepción de Edición In-place (Cambios Menores):** 
Se autoriza al agente a realizar ediciones directamente sobre el archivo de trabajo activo (`in-place`) sin incrementar su versión ni archivarlo, siempre y cuando la modificación consista únicamente en:
- Corrección de erratas, ortografía, tipografía o formato simple.
- Actualización de enlaces a otros archivos.
- Ajustes de comentarios que no afecten a la lógica funcional o técnica del documento.
Para cambios sustanciales en la lógica de negocio, arquitectura o alcances funcionales/técnicos, el procedimiento completo de GATE 0 es estrictamente obligatorio.

---

## 10. ESTRATEGIA DE IDIOMAS Y LOCALIZACIÓN
Dado el entorno global de los proyectos SAP de Grupo HIBERUS y para optimizar el consumo de recursos (tokens):
- **Consulta Previa Obligatoria:** Antes de proceder a la creación de cualquier entregable, documento o propuesta, el agente **DEBE preguntar** al usuario en qué idioma(s) desea los archivos. No se generarán versiones en varios idiomas de forma automática.
- **Archivos Separados:** En caso de requerirse más de un idioma, se deben crear archivos distintos (ej. `..._ES_v1.0.docx` y `..._EN_v1.0.docx`) para evitar documentos bilingües de difícil lectura.
- **Consistencia Técnica:** Los términos técnicos de SAP (ej. 'Storage Location', 'ATP', 'BAPI') se mantendrán preferiblemente en inglés independientemente del idioma del documento para evitar ambigüedades.

---

## 11. SISTEMA DE MEMORIA PERSISTENTE DE PROYECTO (LONG-TERM MEMORY)
Para evitar la pérdida de contexto y directrices de negocio críticas al iniciar nuevas conversaciones/chats o limpiar la sesión:
- **Archivo de Memoria (`00_Project_Memory.md`):** Cada propuesta o proyecto en desarrollo debe contar con un archivo de memoria persistente en su raíz (ej. `Projects/Nombre_Proyecto/00_Project_Memory.md`).
- **Plantilla Estándar:** Al auto-generar un nuevo `00_Project_Memory.md`, el agente DEBE usar como esqueleto la plantilla ubicada en `Standards/project_memory_template.md` para garantizar consistencia estructural entre todos los proyectos.
- **Lectura Obligatoria al Inicio:** Al iniciar cualquier nueva conversación, sesión o cambio de sombrero, el agente **DEBE escanear y leer únicamente este archivo** para recuperar el contexto histórico. Una vez que el `00_Project_Memory.md` existe, **NO se vuelven a escanear** los documentos originales del proyecto (ahorro de tokens).
- **Gate de Validación:** Cuando el agente auto-genera un `00_Project_Memory.md` por primera vez (leyendo documentos locales y/o el chat activo), **DEBE presentar al usuario un resumen de lo extraído** antes de grabarlo en disco. Esto evita memorizar asunciones incorrectas. Una vez que el usuario valide el contenido, se graba.
- **Triggers de Actualización:** El agente actualiza el `00_Project_Memory.md` exclusivamente en estos momentos:
  1. El usuario confirma explícitamente una nueva regla de negocio o decisión estratégica.
  2. Se genera un nuevo entregable activo (nueva versión de propuesta, FS, etc.).
  3. Se cierra una fase SAP Activate (Quality Gate).
  4. El usuario lo solicita directamente.

---

## 12. ⚠️ GATE -1 — VERIFICACIÓN OBLIGATORIA DE `00_Project_Memory.md` ANTES DE ACTUAR

**Cuándo se aplica:** Antes de ejecutar **cualquier acción** (creación, edición, consulta o generación de entregables) sobre una carpeta de proyecto **existente** en [Projects/](Projects/).

**Procedimiento obligatorio (por este orden):**
1. **Verificar** si existe el fichero `00_Project_Memory.md` en la raíz de la carpeta del proyecto afectado.
2. **Si existe:** continuar con la acción solicitada normalmente.
3. **Si NO existe:** el agente DEBE, **antes de realizar la acción solicitada**:
    a. Leer los documentos existentes en la carpeta del proyecto para extraer contexto.
    b. Presentar al usuario un **resumen de lo extraído** (datos generales, reglas de negocio, entregables detectados) para validación. *(Ver §11 — Gate de Validación)*
    c. Una vez el usuario confirme, generar el `00_Project_Memory.md` usando la plantilla `Standards/project_memory_template.md` (renombrándolo de forma estándar con el prefijo `00_`).
    d. Informar al usuario: *"Se ha creado `00_Project_Memory.md` en `[ruta]`. Ahora procedo con la acción solicitada."*
    e. Continuar con la acción solicitada originalmente.

**Excepciones:** Este gate NO aplica cuando la acción es la creación de una carpeta de proyecto **nueva desde cero** (§1 ya cubre ese caso con la creación obligatoria inmediata del `00_Project_Memory.md`).

**Violación = Fallo crítico.** Si el agente realiza cambios sobre un proyecto sin `00_Project_Memory.md` y sin haber ejecutado este gate, se considera un incumplimiento grave equivalente al GATE 0.
