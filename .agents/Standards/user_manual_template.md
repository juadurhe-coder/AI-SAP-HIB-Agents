# SAP USER MANUAL: [NOMBRE DEL MANUAL / PROCESO]
## [Subtítulo del Manual (ej. Advanced Intercompany Drop Shipment en S/4HANA (SD/MM/FI))]

---

| Document Metadata | Details |
| :--- | :--- |
| **Project** | [Project Name & Code (ej. PRJ-IC-DROP-001)] |
| **Client** | [Client Name] |
| **SAP Consultant** | Juan Luis Durán |
| **SAP Module** | [SAP Modules, e.g. SD, MM, FI-CO] |
| **SAP Environment** | [Environment, e.g. S/4HANA 2022] |
| **Version** | v1.0 (Official / Released for Production) |
| **Creation Date** | [Date (DD/MM/YYYY)] |
| **Confidentiality** | **CONFIDENTIAL** — Internal distribution only |

---

[PAGE_BREAK]

## TABLE OF CONTENTS
1. [Process Introduction](#1-process-introduction)
2. [Master Data Configuration & Prerequisites](#2-master-data-configuration--prerequisites)
   - 2.1 [Material Extension](#21-material-extension)
   - 2.2 [Tax Conditions Maintenance](#22-tax-conditions-maintenance)
   - 2.3 [Business Partner Extension](#23-business-partner-extension)
   - 2.4 [Intercompany Pricing Maintenance](#24-intercompany-pricing-maintenance)
3. [End-to-End Test Execution Flow](#3-end-to-end-test-execution-flow)
   - 3.1 [Execution Flow Steps (Preparation, Creation, and Transit)](#31-execution-flow-steps-preparation-creation-and-transit)
   - 3.2 [Execution Flow Steps (Billing and Financial Validations)](#32-execution-flow-steps-billing-and-financial-validations)

---

[PAGE_BREAK]

## 1. Process Introduction

[Describir brevemente el proceso de negocio SAP, los objetivos operativos, la cadena de suministro integrada y los módulos SAP involucrados (SD/MM/FI-CO/PP).]

### Reference Organizational Structure in this Manual

| SAP Entity | Technical Code | Process Description | Country / Role |
| :--- | :--- | :--- | :--- |
| **Selling Company Code** | `[XXXX]` | [Descripción del rol de venta] | [País] / Seller |
| **Supplying Company Code** | `[YYYY]` | [Descripción del rol de expedición física] | [País] / Supplier |
| **Virtual Transit Plant** | `[ZZZZ]` | [Descripción del centro virtual de valoración] | [País] / Transit |

---

> 📷 **[SCREENSHOT PLACEHOLDER 01: Process Overview & Value Chain Diagram]**  
> *Description: High-level architectural flowchart showing document flow between Customer, Selling Sales Org, Supplying Plant, and Virtual Transit Plant.*

---

## 2. Master Data Configuration & Prerequisites

[Detallar los datos maestros clave necesarios previa ejecución del proceso.]

### 2.1 Material Extension (MM01)

[Pasos y vistas obligatorias a seleccionar en la transacción `MM01`]:

| Subject Area | Master Data Views to Select |
| :--- | :--- |
| **Sales (SD)** | Sales: Sales Org. Data 1 & 2, Sales: General/Plant Data |
| **Purchasing & Planning (MM/PP)** | Purchasing, MRP 1, MRP 2, MRP 3, MRP 4 |
| **Storage (MM)** | Plant Data / Storage 1 & 2 |
| **Finance & Costing (FI-CO)** | Accounting 1 & 2, Costing 1 & 2 |

---

> [!WARNING]  
> **CRITICAL CONFIGURATION ALERT:**  
> [Detallar cualquier parámetro estrictamente obligatorio cuya omisión provoque errores en la ejecución automática del proceso].

---

> 📷 **[SCREENSHOT PLACEHOLDER 02: Transaction MM01 - View Selection & Org Levels]**  
> *Description: MM01 pop-up dialog showing highlighted view selections and organizational levels.*

---

### 2.2 Maintenance of Tax Conditions (VK11)

| Indicator | Tax Name | Application in the Process |
| :--- | :--- | :--- |
| **[CODE]** | [Tax Name] | [Application Description] |

---

> 📷 **[SCREENSHOT PLACEHOLDER 03: Transaction VK11 - Tax Maintenance Matrix]**  
> *Description: VK11 condition table grid populated with Sales Org, Plant, Countries, and Tax Codes.*

---

### 2.3 Creation and Extension of Business Partners (BP)

> [!NOTE]  
> **MASTER DATA INTEGRATION:**  
> [Indicar si los Business Partners se crean desde Salesforce u otro sistema origen SOT, o si se mantiene directamente en SAP via BP].

---

### 2.4 Maintenance of Intercompany Pricing (Condition PI01 / VK11 / MEK1)

---

## 3. End-to-End Test Execution Flow

### 3.1 Execution Flow Steps (Preparation, Creation, and Transit)

| Step | Action (Transaction / App Fiori) | Process Description and Expected Result |
| :---: | :--- | :--- |
| **0** | **Prior Master Data Setup**<br>`MM01`, `VK11`, `BP` | Verify sample material and tax/BP records. |
| **1** | **Create Standard Sales Order**<br>`VA01` | Create standard sales order (Order Type `OR`). |
| **2** | **Verify Flow in Monitor**<br>Fiori App `F4854` | Validate flow and documents automatically generated. |

---

> 📷 **[SCREENSHOT PLACEHOLDER 04: Transaction VA01 / Fiori App F4854]**  
> *Description: Sales order creation screen or Fiori Value Chain graph showing step progress.*

---

### 3.2 Execution Flow Steps (Billing and Financial Validations)

| Step | Action (Transaction / App Fiori) | Process Description and Expected Result |
| :---: | :--- | :--- |
| **11** | **External Customer Billing**<br>`VF01` | Issue commercial invoice to external customer. |
| **12** | **Create Intercompany Invoice**<br>`VF01` (Type `ZIV2`) | Issue internal invoice between company codes. |
| **13** | **FI Accounting Document Review**<br>`FB03` | Inspect automated financial accrual, COGS, and clearing line items. |

---

> [!TIP]  
> **FINANCIAL ERROR MONITORING RECOMMENDATION:**  
> [Detallar recomendaciones clave para la resolución de errores comunes durante la ejecución].
