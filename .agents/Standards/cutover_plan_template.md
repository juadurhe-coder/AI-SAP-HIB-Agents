# CUTOVER & GO-LIVE PLAN: [PROYECTO / ENTREGABLE]
## [Subtítulo del Plan de Traspaso a Producción y Runbook]

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

## 1. Cutover Strategy & Windows

### 1.1 Go-Live Timeline
- **Cutover Start:** `[Fecha/Hora]`
- **Go-Live Target:** `[Fecha/Hora]`
- **Hypercare Period:** `[Duración, ej. 2 Semanas]`

---

[PAGE_BREAK]

## 2. Sequential Cutover Checklist & Task Execution

| Seq | Phase | Task Description | Owner | Target System | Status |
| :---: | :--- | :--- | :--- | :---: | :---: |
| 1 | Pre-Cutover | Congelar desarrollos y solicitudes de transporte | Basis / Dev | DEV/QAS | [ ] Pending |
| 2 | Transport | Importar órdenes de transporte en PRD | Basis | PRD | [ ] Pending |
| 3 | Cutover Data | Carga de datos maestros delta (VK11 / BP) | Functional | PRD | [ ] Pending |
| 4 | Verification | Sanity Check post-Go-Live | PMO Lead | PRD | [ ] Pending |

---

[PAGE_BREAK]

## 3. Rollback & Contingency Plan

### 3.1 Rollback Triggers
[Condiciones bajo las cuales se activaría un rollback completo antes de la ventana de Go-Live.]

### 3.2 Contingency Actions
1. Desactivar sustitución / BAdI en PRD.
2. Revertir transporte mediante paquete de rollback si aplica.
