# [HISTORICAL REFERENCE] SAP TEAM ORCHESTRATION — Drop Shipment Project

> ⚠️ **NOTA:** Este archivo es una referencia histórica del proyecto "Advanced Intercompany Drop Shipment" (Plant 4800/4900). Para la orquestación global del ecosistema multi-agente, consultar `Agents/master_orchestrator.md`.

# Workflow: SAP TEAM ORCHESTRATION (Activate Lifecycle)

## TEAM MEMBERS
1.  Intake Analyst: Triages incoming requests, detects missing information, and generates draft specifications.
2.  Functional Architect: Leads Business Analysis, Explore Phase (FS/BPD), and Logic Design.
3.  Fiori Developer: Responsible for Frontend construction, UI Design, and Fiori UX.
4.  SAP Backend Developer: Responsible for Service definition, RAP/CAP logic, and Core integration.
5.  PMO Reviewer: Audits quality, governs SAP Activate, and performs Quality Gates.

## ORCHESTRATION STEPS

### PHASE 0: INTAKE & DRAFT
1.  Intake Analyst receives the user request and classifies its type (FS/Proposal/Gap/CR).
    - *Mandatory*: Must consult `Skills/structured_input_templates.md` and `Skills/communication_protocols.md`.
2.  Intake Analyst evaluates completeness against the template. If <70% → executes `Workflow/intake_questionnaire.md`.
3.  Intake Analyst generates a draft specification skeleton (`Workflow/spec_draft_workflow.md`).
4.  User reviews and approves the draft → Transition to Phase 1.

### PHASE 1: EXPLORE & DESIGN
1.  Functional Architect develops the full Functional Specification (FS) using the approved draft as base (Consult `Skills/drop_shipment_functional.md`).
    - *Mandatory*: Must follow Draft-First Protocol and `Skills/communication_protocols.md`.
2.  PMO Reviewer validates the FS for methodological compliance.

### PHASE 2: REALIZATION (TECHNICAL CONSTRUCTION)
1.  SAP Backend Developer designs the Data Model (CDS) and Service (OData V4) based on the FS.
    - *Mandatory*: Must consult `Skills/abap_cloud_rap.md` and `Skills/clean_core_extensions.md`.
2.  Fiori Developer designs the UI layout and navigations based on the Backend Service and FS.
    - *Mandatory*: Must consult `Skills/fiori_design.md`.

### PHASE 3: QUALITY GATE & SIGN-OFF
1.  PMO Reviewer conducts a holistic review:
    - Code check from Backend Developer.
    - UI check from Fiori Developer.
    - Alignment check with Functional Specification.
2.  PMO Reviewer issues the "Quality Gate Approval" or detailed remediation.
