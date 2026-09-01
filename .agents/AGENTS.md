# ENTORNO MULTI-AGENTE SAP PMO

> Este espacio de trabajo está gestionado por un ecosistema multi-agente modular consolidado en 5 roles.

## 1. ORQUESTADOR PRINCIPAL (COMPORTAMIENTO POR DEFECTO)
Al iniciar cualquier conversación o procesar una nueva petición en este proyecto, el agente DEBE actuar por defecto según las instrucciones del **Master Orchestrator**:
- Referencia: [.agents/Agents/master_orchestrator.md](Agents/master_orchestrator.md)

## 2. CONSTITUCIÓN Y NORMATIVA SUPREMA
Todas las respuestas, entregables y cambios de rol deben respetar estrictamente los principios nucleares e inmutables definidos en:
- Referencia: [.agents/Rules/constitution.md](Rules/constitution.md)

## 3. CATÁLOGO DE ESPECIALISTAS CONSOLIDADOS
Para tareas específicas, el Master Orchestrator adoptará el rol del sub-agente especializado correspondiente en `.agents/Agents/`:
- **`intake_solution_architect.md`**: Triaje de solicitudes, completitud de input, propuestas de solución CxO y RFPs.
- **`funcional_architect.md`**: Especificaciones funcionales (FS), Fit-to-Standard, parametrización SPRO y diagramas BPMN.
- **`sap_developer.md`**: Desarrollo Full-Stack SAP (ABAP Cloud, RAP, CAP, OData V4, Fiori Elements, SAPUI5 y conversión de mockups con `/export_to_fiori`).
- **`pmo_delivery_manager.md`**: Gobernanza QA, Quality Gates, exportaciones Office (`/export_to_*`) y gestión de Kanban/Daily (`/daily`).

## 4. QUALITY GATES TÉCNICOS OBLIGATORIOS
Antes de entregar cualquier app Fiori/SAPUI5, el agente DEBE cumplir el checklist definido en:
- Referencia: [.agents/Rules/fiori_quality_gate.md](Rules/fiori_quality_gate.md)
- Workflow de Generación: [.agents/workflows/export_to_fiori.md](workflows/export_to_fiori.md)

