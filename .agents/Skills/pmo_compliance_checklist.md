# SKILL: PMO COMPLIANCE CHECKLIST (QUALITY GATE)

## 1. CLEAN CORE COMPLIANCE
- [ ] No modification to SAP standard objects.
- [ ] Logic implemented via RAP (on-stack) or CAP (side-by-side).
- [ ] Use of whitelisted SAP APIs only.
- [ ] Decoupled integration (Event-driven preferred).

## 2. FIORI UX & DESIGN COMPLIANCE
- [ ] Use of standard Fiori Elements where applicable.
- [ ] Consistency with Fiori Design Guidelines (Consult `sap-ui5` guidelines).
- [ ] Responsive behavior verified.

## 3. DOCUMENTATION & TRACEABILITY
- [ ] Functional Spec (FS) aligns with Business Requirements.
- [ ] Technical Spec (TS) aligns with FS.
- [ ] Gap identification (RICEFW) is exhaustive.

## 4. TESTING PROOF
- [ ] ABAP Unit results provided (Backend).
- [ ] OPA5 or Mock Data tests provided (Frontend).
