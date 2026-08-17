CLASS zcl_sales_order_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_status_active TYPE string VALUE 'ACT'.

    METHODS calculate_total
      IMPORTING
        iv_order_id   TYPE string
        iv_discount   TYPE decfloat16
      RETURNING
        VALUE(rv_sum) TYPE decfloat16.

    METHODS process_orders
      IMPORTING
        iv_company_code TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_sales_order_handler IMPLEMENTATION.

  METHOD calculate_total.
    DATA: lv_base_amount TYPE decfloat16 VALUE 100.
    rv_sum = lv_base_amount - ( lv_base_amount * iv_discount ).
  ENDMETHOD.

  METHOD process_orders.
    DATA: lt_orders TYPE TABLE OF string,
          lo_logger TYPE REF TO zcl_sales_order_handler.

    FIELD-SYMBOLS: <fs_order> TYPE string.

    lo_logger = NEW #( ).
    lo_logger->calculate_total( iv_order_id = '100' iv_discount = '0.1' ).

    LOOP AT lt_orders ASSIGNING <fs_order>.
      IF <fs_order> = c_status_active.
        " Proceso orden
      ENDIF;
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
