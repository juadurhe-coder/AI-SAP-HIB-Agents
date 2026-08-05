---
description: Ejecuta tu Daily Standup con el Delivery Manager para conocer los bloqueos y prioridades del día
---

# WORKFLOW: KANBAN DAILY STAND-UP

Este workflow despierta al agente `Delivery Manager` para que haga el seguimiento a primera hora.

## INSTRUCCIONES AUTOMÁTICAS (Para el Agente):
1. **Adopta tu rol:** Asume silenciosamente el rol que dicta `.agents/Agents/delivery_manager.md`.
2. **Lee la base de datos:** Ejecuta la herramienta de `view_file` para leer obligatoriamente `Kanban.md`.
3. **Analiza el estado:** Identifica qué está en STOPPER, DOING, BACKLOG y DONE.
4. **Genera el reporte:** Saluda al usuario y preséntale el formato estructurado definido en tus guidelines (Resumen Ejecutivo, Stoppers, En Curso, Input Requerido).
5. **Ofrece acción:** Pregunta al usuario si desea mover alguna tarea, crear nuevas o si da alguna indicación sobre los stoppers.
