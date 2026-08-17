CLASS zcl_secure_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process_safe
      IMPORTING
        iv_sales_order TYPE string.
ENDCLASS.

CLASS zcl_secure_demo IMPLEMENTATION.

  METHOD process_safe.
    DATA: lt_orders TYPE TABLE OF string.

    AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
      ID 'ACTVT' FIELD '03'
      ID 'DICBERCLS' DUMMY.

    IF sy-subrc = 0.
      SELECT salesorder, customer
        FROM i_salesordervdm
        INTO TABLE @lt_orders
        WHERE salesorder = @iv_sales_order.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
