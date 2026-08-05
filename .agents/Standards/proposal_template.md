<!-- 
INSTRUCCIÓN DE UBICACIÓN MANDATORIA:
Este archivo debe crearse SIEMPRE dentro de una subcarpeta en '00_Proposals/'.
NO mover a 'Management/Projects/' hasta aprobación explícita del cliente.
-->
# PROPOSAL: [PROJECT NAME] ([TECHNICAL CODES])

---

| Document Metadata | Details |
| :--- | :--- |
| **Project** | [Project Name] |
| **Client** | [Client Name] |
| **SAP Consultant** | Juan Luis Durán |
| **SAP Module** | [SAP Module, e.g. SD, MM] |
| **SAP Environment** | [Environment, e.g. S/4HANA 2022] |
| **Version** | v1.0 |
| **Creation Date** | [Date] |

---

[PAGE_BREAK]

## 1. Current Situation and Problem Statement

### Current Situation
[High-level description of the central problem]

[List current process steps]:
- [Step 1: e.g., Extraction from S/4HANA]
- [Step 2: e.g., Processing in BW / Excel]
- [Step 3: e.g., Manual VK11 upload]

[Concluding paragraph highlighting risks, e.g., "This process is time-consuming, error-prone, and unsustainable due to the decommissioning of BW..."]

### Reasons for Not Using Standard
[Explain why standard SAP functionality doesn't work for this specific case]:
- [Distortion/Gap 1: e.g., COGS distortions due to machine ages]
- [Distortion/Gap 2: e.g., Product group level too aggregated]

---

## 2. Proposed Solution
[High-level description of the solution: centralized Dashboard, Fiori application, automatic fetching, and bulk-generation.]

### Benefits
- [Benefit 1: e.g., Avoid manual offline calculations in Excel]
- [Benefit 2: e.g., Avoid manual creation of pricing conditions]
- [Benefit 3: e.g., Improve traceability with integrated view logs]
- [Benefit 4: e.g., Mitigate mathematical errors during currency conversions]

---

## 3. Proposed Design

### Configuration Table (Custom Table)
[Explanation of markup and parameter storage.]

**Key fields:**
- [Description] ([FIELDNAME])
- [Description] ([FIELDNAME])
- [Description] ([FIELDNAME])

**Maintenance:** [Tool, e.g., SAP Fiori Application / SM30]

### Backend Logic
[Technical explanation, e.g., "Calling standard BAPIs in the background (BAPI_PRICES_CONDITIONS) to generate records."]

**Object Configuration:**
- **Object:** [Transaction/Exit, e.g., VK11 / MV45AFZZ]
- **Condition/Logic:** [Code, e.g., PI01 / Check table validation]

---

## 4. Cost and Effort Estimation

| Task / Phase | Description and Deliverables | Estimated Effort |
| :--- | :--- | :---: |
| **Phase 1:** [Nombre Tarea 1] | [Descripción: e.g., Talleres de definición y consolidación de requisitos.] | **[X] hours** |
| **Phase 2:** [Nombre Tarea 2] | [Descripción: e.g., Creación de tablas backend personalizadas y lógica de negocio.] | **[X] horas** |
| **Phase 3:** [Nombre Tarea 3] | [Descripción: e.g., Desarrollo de SAP Fiori Dashboard y mapeo de UI.] | **[X] horas** |
| **Phase 4:** [Nombre Tarea 4] | [Descripción: e.g., UAT, pruebas integrales finales y despliegue.] | **[X] horas** |
| **TOTAL ESTIMATED** | **Total estimated effort for project implementation** | **[X] hours** |


