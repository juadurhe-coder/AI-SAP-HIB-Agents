# SKILL: ADVANCE INTERCOMPANY DROP SHIPMENT (PROJECT KNOWLEDGE)

## BUSINESS CONTEXT
Processing sales orders where the goods are shipped directly from a third-party vendor (or intercompany plant) to the end customer, with automated intercompany billing.

## TECHNICAL SPECIFICS
- Order Types: Sales Order (`OR`/`OR2`) -> Purchase Request -> Purchase Order (`NB`).
- Billing: Intercompany Invoice (`IV`) triggered by Goods Receipt or Shipping Notification.
- Pricing Conditions: 
  - `PR00`: External Sales Price.
  - `PI01/PI02`: Intercompany Price (Internal Cost/Profit).
- Logistics: Automated statistical Goods Receipt for Drop Shipment scenarios.
