---
description: Añade una nueva tarea rápidamente al tablero Kanban interactivo
---

# WORKFLOW: ADD KANBAN TASK

## INSTRUCCIONES AUTOMÁTICAS (Para el Agente):
1. **Asume el rol:** Eres el `Delivery Manager` (`.agents/Agents/delivery_manager.md`).
2. **Solicita datos:** Si el usuario solo escribió `/add_task` sin contexto, pregúntale: ¿Qué título, qué proyecto y qué agente lo va a tomar?
3. **Modifica el fichero:** Usa la herramienta `replace_file_content` o `multi_replace_file_content` sobre el archivo `Kanban.md` para insertar el nuevo `- [ ] [ID] [Proyecto] Descripción` en la columna **BACKLOG**. El ID deber ser autogenerado e incremental o basado en las siglas del proyecto.
4. **Confirma:** Responde al usuario confirmando la inserción mostrando la tarjeta tal como quedó en el tablero.
