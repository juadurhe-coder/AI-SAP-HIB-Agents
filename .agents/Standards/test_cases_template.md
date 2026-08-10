# UAT & TEST CASES: [NOMBRE DEL PROYECTO / MÓDULO]
## [Subtítulo del Plan de Pruebas (ej. Pruebas de Aceptación UAT e Integración E2E)]

---

| Document Metadata | Details |
| :--- | :--- |
| **Project** | [Project Name & Code] |
| **Client** | [Client Name] |
| **SAP Consultant** | Juan Luis Durán |
| **SAP Module** | [SAP Modules, e.g. SD, MM, FI-CO] |
| **SAP Environment** | [Environment, e.g. S/4HANA 2022] |
| **Version** | v1.0 |
| **Creation Date** | [Date (DD/MM/YYYY)] |

---

[PAGE_BREAK]

## 1. Test Strategy & Objectives

### 1.1 Scope of Testing
[Describir los escenarios cubiertos (Unit Testing, Integration Testing, User Acceptance Testing - UAT).]

### 1.2 Prerequisites & Master Data Setup
- [ ] Datos Maestros de Materiales activos en centro `[XXXX]`
- [ ] Business Partners configurados con funciones de interlocutor `[YY]`

---

[PAGE_BREAK]

## 2. Step-by-Step Test Scenarios

### Scenario 01: [Nombre del Escenario de Prueba]

| Step | Operation / Action | Transaction / App | Input Data | Expected Result | Pass / Fail |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | Crear Pedido de Venta | `VA01` | Org. Venta `1000`, Mat `M-01` | Pedido guardado sin bloqueos | [ ] Pass |
| 2 | Verificación de Facturación | `VF01` | Entrega `800001` | Factura creada e integrada en FI | [ ] Pass |

---

[PAGE_BREAK]

## 3. UAT Sign-off & Acceptance

| Role | Name | Date | Signature / Approval |
| :--- | :--- | :---: | :---: |
| **Lead Functional Consultant** | Juan Luis Durán | [Date] | Approved |
| **Business Key User / Client** | [Client Lead] | [Date] | Pending Sign-off |
