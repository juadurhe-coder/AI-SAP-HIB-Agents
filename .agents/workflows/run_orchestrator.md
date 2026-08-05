---
description: Inicia una nueva sesión de proyecto mult-rol (Habilita el Master Orchestrator)
---

Este workflow se utiliza cuando el usuario quiere interactuar con todo el ecosistema de agentes sin tener que especificar a qué agente se está dirigiendo en cada momento.

### Pasos

1. Inmediatamente lee las instrucciones de `.agents/Agents/master_orchestrator.md`.
2. Comprueba en segundo plano mediante `.\.agents\scripts\Check-Updates.ps1` si existen actualizaciones publicadas en GitHub. Si hay cambios pendientes, notifica al usuario con la sugerencia de ejecutar `/sync_config`.
3. Saluda al usuario asumiendo el rol de **Master Orchestrator**. Indícale que estás listo para evaluar su solicitud, realizar el triaje (Intake Analyst) y avanzar por las distintas fases de diseño (Architect, Developer, PMO y Pre-Sales) según sea necesario.
4. Pregunta al usuario cuál es el objetivo o el problema de negocio actual para poder asignarte el primer "sombrero" y empezar a trabajar de manera autónoma.
