CLASS zcl_fast_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS run_optimized_queries.
ENDCLASS.

CLASS zcl_fast_demo IMPLEMENTATION.

  METHOD run_fast_queries.
    DATA: lt_headers TYPE TABLE OF string,
          lt_items TYPE TABLE OF string,
          ls_header TYPE string.

    " Explicit column selection
    SELECT order_id, customer_id
      FROM zorders
      INTO TABLE @lt_headers
      WHERE status = 'ACT'.

    " FAE with IS NOT INITIAL guard
    IF lt_headers IS NOT INITIAL.
      SELECT item_id, order_id, net_amount
        FROM zorder_items
        FOR ALL ENTRIES IN @lt_headers
        WHERE order_id = @lt_headers-table_line
        INTO TABLE @lt_items.
    ENDIF.

    " In-memory processing without DB queries inside loop
    LOOP AT lt_headers INTO ls_header.
      " Calculation in memory
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
