# 📊 COMMAND CENTER - KANBAN BOARD

> **Delivery Manager:** Lee, edita y mantiene este fichero como fuente única de verdad.
> **Prefixes:** `[PRJ-...]` (Project), `[INC-...]` (Incidencias), `[SR-...]` (Service Requests)
> **Format:** `- [ ] [ID] [Title] Description (F: @funcional_architect, D: @sap_backend_developer) {Tags}`

## 🚨 STOPPERS & BLOCKED (Requieren atención inmediata)
- [ ] `[PRJ-ETX-001]` **[Eurotex-SCRAP]** Error en creación de precios: incluir lógica multicanal/centros (tiendas). Ref: `Projects/Eurotex_SCRAP/` (F: Juan, D: Joan) {Blocked_Refactoring}

## 🟡 DOING (Trabajo en curso)
- [ ] `[INC-107919]` **[EMEA ZFOC]** Optimización facturación muestras: copiar FD a ZFD y revisar config/código ZFOC (F: Juan, D: Joan) {In_Progress}
- [ ] `[ADM-001]` **[Ecosystem]** Verificación inicial del tablero (F: @delivery_manager, D: -)
- [ ] `[PRJ-AVZ-001]` **[Avizor-FTP]** Integración vía CSV/FTP - En UAT. Ref: `Projects/Avizor_FTP/` (F: @externo, D: @externo) {UAT}
- [ ] `[PRJ-OTK-001]` **[Oetiker-AdobeForms]** Creación 4 formularios Adobe (Est: 10 días). Ref: `Projects/Oetiker_AdobeForms/` (F: Juan, D: Joan)
- [ ] `[PRJ-REB-001]` **[Settlement Management]** Numeración dinámica - En UAT OEQ (F: Juan, D: Joan) {Deadline_Apr_16}
- [ ] `[PRJ-REB-005]` **[Rebates-Fiori]** Integración OData (Mockup validado). Ref: `Projects/Fiori_Rebate/` (F: Juan, D: @fiori_developer) {In_Progress}
- [/] `[PRJ-FRDD-001]` **[FRDD]** Flexible Proposal of Delivery Dates - En UAT OEQ, documento funcional y guía generados, pendiente capturas (F: Juan, D: Joan) {S4H_Sales, Tester: Lori}
- [ ] `[PRJ-IC-DROP-001]` **[Drop Shipment]** En UAT con usuarios. Ref: `Projects/Advance Intercompany Drop Shipment/` (F: Juan, D: Joan) {UAT}
- [ ] `[PRJ-RFI-PRC-001]` **[IC Pricing]** Generar presentación PPTX para propuesta final. Ref: `Projects/IC Pricing/` (F: @pre_sales_solution_architect, D: -) {Design_Phase}
- [ ] `[PRJ-PTC-001]` **[PTC OPL Polonia]** Fase de Diseño / BPD. Ref: `Projects/PTC-OPL-Polonia/` (F: Paul/Juan, D: Pendiente) {Kick_Off_Done}
- [ ] `[PRJ-IC-DROP-006]` **[Drop Shipment-Issue]** Corrección ZIV2: Aplicar **Nota SAP 3385746** (F: Juan, D: Joan) {In_Progress}
- [ ] `[PRJ-76551]` **[ZSD_PRICE_REPORT]** Habilitar condiciones (ZPGR, AS01, PR00, KA02) y corregir filtro de fecha (Opción 1 - Fecha Única de Referencia). Ref: `Projects/ZSD_PRICE_REPORT_Modification_76551/` (F: Juan, D: Joan) {In_Progress}
- [ ] `[PRJ-FRM-001]` **[Fiori-Role-Manager]** Value proposal and security matrix architecture definition. Ref: `Projects/Fiori_Role_Manager/` (F: Juan, D: AI) {Design_Phase}
- [/] `[INC-108462]` **[SD OTD Persistence]** Diseño funcional completado y aprobado, traspasado a desarrollo backend. Ref: `Projects/SD_OTD/` (F: Juan, D: Joan) {In_Progress}
- [ ] `[INC-107037]` **[OPL Polonia (Lithuania Ext)]** Automatización Facturación VF04 & Job Fondo. Lituania priorizada en Fase 1 (Go-Live Junio/Julio 2026). Ref: `Projects/Poland_Lithuania_Automatic_Billing/` (F: Juan, D: Joan) {Design_Phase}
- [ ] `[PRJ-EMEA-PRC-001]` **[EMEA SSA Pricing Standardization]** Alineación y estandarización del origen de determinación de precios (VK12 vs SSA) para acuerdos de entrega. Ref: `Projects/EMEA_SSA_Pricing_Standardization/` (F: Juan, D: Joan) {Design_Phase}

## 🔵 BACKLOG (Tareas pendientes)

### 📌 PROJECTS
- [ ] `[PRJ-IC-DROP-002]` **[Drop Shipment-Cutover]** Creación registros condición impuestos (MWST) en PRO (F: Juan, D: Joan) {Cutover}
- [ ] `[PRJ-IC-DROP-003]` **[Drop Shipment-Cutover]** Sincronización de precios: Réplica Compra -> Venta (F: Juan, D: Joan) {Cutover, Pricing_Strategy}
- [ ] `[PRJ-IC-DROP-004]` **[Drop Shipment-Forms]** Cambios en formularios de Factura (F: Juan, D: Joan) {Design_Phase}
- [ ] `[PRJ-IC-DROP-005]` **[Drop Shipment-Forms]** Cambios en formularios de Entrega (F: Juan, D: Joan) {Design_Phase}
- [ ] `[PRJ-REB-002]` **[Rebates-Numbering]** (INC-103148) Corrección de solapamiento de rangos RV_BELEG y W_LFAKTURA en facturación (F: Juan, D: Joan) {Critical}
- [ ] `[PRJ-REB-004]` **[Rebates-Output]** (INC-77287) Configuración Access Sequence (F: Juan, D: -)
- [ ] `[PRJ-BTP-AI-001]` **[BTP AI]** Arquitectura BAdI a OData (F: Juan, D: @sap_backend_developer)
- [ ] `[INC-103563]` **[Stock Reservation]** Implementación de reserva de stock (F: Juan, D: Joan) {Validated}
- [ ] `[INC-104868]` **[Storage Location Automation]** Automatización de determinación de almacén (F: Juan, D: Joan) {Validated}
- [ ] `[INC-77287]` **[Adobe Form Reuse]** Implementación de reutilización de formularios factura para Settlement (F: Juan, D: Joan) {Validated}


### 🛠️ INCIDENCIAS (Tickets Fix)
*(Vacío actualmente)*

### 📝 SERVICE REQUESTS (Evolutivos cortos)
- [ ] `[SR-INDIA-FORM]` **[Oetiker-IndiaForm]** Modificaciones agrupadas formulario factura India. Mariña revisando requerimientos antes de pasar a desarrollo. Ref: `Projects/Oetiker_AdobeForms/` (F: Mariña, D: Joan) {Blocked_by_PRJ-OTK-001}
- [ ] `[INC-107037-POD]` **[POD Billing Date]** Automatización de fecha de factura desde POD. Ref: `Projects/POD_Billing_Automation/` (F: Juan, D: Joan) {S4H_Sales, Clean_Core}
- [ ] `[INC-107037-ZERO]` **[Zero-Value Invoice Prevent]** Bloqueo/aviso en creación de entregas para posiciones con valor cero (Polonia/Lituania). Ref: `Projects/Poland_Lithuania_Automatic_Billing/` (F: Juan, D: Joan) {Backlog}
- [ ] `[INC-107037-DATA]` **[BP Aggregation Cleanup]** Revisión/depuración de parámetros de agregación en datos maestros de clientes (Volvo, etc.). Ref: `Projects/Poland_Lithuania_Automatic_Billing/` (F: Juan, D: Soporte) {Backlog}
- [ ] `[INC-107037-TRANS]` **[Invoice Transmission Automation]** Fase 2: Automatización de la transmisión de facturas vía EDI/email y transacción VF31 (Lituania). Ref: `Projects/Poland_Lithuania_Automatic_Billing/` (F: Juan, D: Joan) {Backlog}

## 🟢 DONE (Completado recientemente)
- [x] `[INC-105295]` **[ZLK-Zero-Qty]** DN'S WITH POSITONS OF 0 PZS: Parametrización ZLKN (OVLP) completada y transportado a producción. Ref: `Projects/INC-105295_Prevent_Zero_Qty/105295_Explore_05_Prevent_Zero_Qty_v1.0.md`
- [x] `[INC-VAL-001]` **[Valresa-SCRAP]** Error en programa SCRAP: MAST hardcodeada (7->1) solucionado en PRO por Joan. Ref: `Projects/Valresa_SCRAP/` (F: Juan, D: Joan) {Bug_Fix_Completed}
- [x] `[PRJ-REB-003]` **[Rebates-Forms]** Propuesta técnica de reutilización Adobe Forms (WBRK/WBRP) finalizada.
- [x] `[INC-108044]` **[FRDD]** Autorizaciones SAP concedidas para Joan.
- [x] `[ADM-000]` **[Ecosystem]** Auditoría y optimización del sistema multi-agente finalizada
