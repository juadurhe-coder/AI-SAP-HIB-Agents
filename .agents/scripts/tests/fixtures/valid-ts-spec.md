# Especificación Técnica Backend - Órdenes de Venta (04_TS_Backend_Orders.md)

## 1. Componentes Reutilizables y Helpers
Se utilizará la clase helper `ZCL_SALES_UTILITY` para el formateo de datos y validaciones transversales.

## 2. Clean Core y Released APIs
El modelo de datos consume la vista CDS liberada `I_SalesOrder` y la interfaz `ZI_SalesOrder_Ext`. Queda prohibido el acceso a tablas directas.

## 3. Arquitectura RAP
- Interface View: `ZI_SalesOrder`
- Projection View: `ZC_SalesOrder`
- Behavior Definition: `ZI_SalesOrder` (Managed)
- Service Binding: `ZSRVB_SALES_ORDER_O4` (OData V4)

## 4. Estrategia de Pruebas Unitarias
Se implementarán pruebas unitarias con **ABAP Unit** y Test Doubles / Mocking para la capa de persistencia y servicios externos.
