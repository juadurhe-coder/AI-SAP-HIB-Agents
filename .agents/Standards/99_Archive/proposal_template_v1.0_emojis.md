<!-- 
INSTRUCCIÓN DE UBICACIÓN MANDATORIA:
Este archivo debe crearse SIEMPRE dentro de una subcarpeta en '00_Proposals/'.
NO mover a 'Management/Projects/' hasta aprobación explícita del cliente.
-->
# 🚀 PROPOSAL: [PROJECT NAME] ([TECHNICAL CODES])

**Date:** [Manual Entry: Date]  
**SAP Consultant:** [Manual Entry: Name]

---

## 🔍 1. SITUACIÓN ACTUAL (CURRENT SITUATION)
**Problema:** [High-level description of the central problem]

[List current process steps]:
* 🔴 [Step 1: e.g., Extraction from S/4HANA]
* 🔴 [Step 2: e.g., Processing in BW / Excel]
* 🔴 [Step 3: e.g., Manual VK11 upload]

[Concluding paragraph highlighting risks, e.g., "This process is time-consuming, error-prone, and unsustainable due to the decommissioning of BW..."]

### ⚠️ Razones para no usar el Estándar (Reasons for Not Using Standard)
[Explain why standard SAP functionality doesn't work for this specific case]:
* 🚫 [Distortion/Gap 1: e.g., COGS distortions due to machine ages]
* 🚫 [Distortion/Gap 2: e.g., Product group level too aggregated]

---

## 💡 2. SOLUCIÓN PROPUESTA (PROPOSED SOLUTION)
[High-level description of the solution: centralized Dashboard, Fiori application, automatic fetching, and bulk-generation.]

**Beneficios:**
* ✅ [Benefit 1: e.g., Avoid manual offline calculations in Excel]
* ✅ [Benefit 2: e.g., Avoid manual creation of pricing conditions]
* ✅ [Benefit 3: e.g., Improve traceability with integrated view logs]
* ✅ [Benefit 4: e.g., Mitigate mathematical errors during currency conversions]

---

## 🛠️ 3. DISEÑO PROPUESTO (PROPOSED DESIGN)

### 📊 Tabla de Configuración (Custom Table)
[Explanation of markup and parameter storage.]

**Campos clave:**
* [Description] ([FIELDNAME])
* [Description] ([FIELDNAME])
* [Description] ([FIELDNAME])

**Mantenimiento:** [Tool, e.g., SAP Fiori Application / SM30]

### ⚙️ Lógica de Backend (Backend Logic)
[Technical explanation, e.g., "Calling standard BAPIs in the background (BAPI_PRICES_CONDITIONS) to generate records."]

**Configuración de Objetos:**
* **Objeto:** [Transaction/Exit, e.g., VK11 / MV45AFZZ]
* **Condición/Lógica:** [Code, e.g., PI01 / Check table validation]

---

## 📅 4. ESTIMACIÓN DE ESFUERZOS Y COSTES (COST & EFFORT ESTIMATION)

| Tarea / Fase | Descripción y Entregables | Esfuerzo Estimado |
| :--- | :--- | :---: |
| **🔵 Tarea 1:** [Nombre Tarea 1] | [Descripción: e.g., Talleres de definición y consolidación de requisitos.] | **[X] horas** |
| **🔵 Tarea 2:** [Nombre Tarea 2] | [Descripción: e.g., Creación de tablas backend personalizadas y lógica de negocio.] | **[X] horas** |
| **🔵 Tarea 3:** [Nombre Tarea 3] | [Descripción: e.g., Desarrollo de SAP Fiori Dashboard y mapeo de UI.] | **[X] horas** |
| **🔵 Tarea 4:** [Nombre Tarea 4] | [Descripción: e.g., UAT, pruebas integrales finales y despliegue.] | **[X] horas** |
| **📊 TOTAL ESTIMADO** | **Esfuerzo total estimado para la implementación del proyecto** | **[X] horas** |

---

## 🖼️ 5. ADJUNTO: MOCKUP DE INTERFAZ DE USUARIO (USER INTERFACE MOCKUP)
<!-- 
REGLA DE ORO: Si la propuesta NO incluye una parte de Fiori/UI (ej. solo lógica backend o configuración), 
esta sección DEBE ser eliminada completamente y NO se debe generar ningún mockup.
-->
Double click the icon below to open the interactive Fiori Dashboard Mockup simulation in your web browser:
[OLE EMBED PLACEHOLDER]
