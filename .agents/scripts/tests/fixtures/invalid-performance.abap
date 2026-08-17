CLASS zcl_slow_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS run_slow_queries.
ENDCLASS.

CLASS zcl_slow_demo IMPLEMENTATION.

  METHOD run_slow_queries.
    DATA: lt_headers TYPE TABLE OF string,
          lt_items TYPE TABLE OF string,
          ls_header TYPE string.

    " 1. SELECT *
    SELECT * FROM zorders INTO TABLE lt_headers.

    " 2. FOR ALL ENTRIES without IS NOT INITIAL check
    SELECT item_id, order_id
      FROM zorder_items
      FOR ALL ENTRIES IN lt_headers
      WHERE order_id = lt_headers-table_line
      INTO TABLE lt_items.

    " 3. SELECT inside LOOP
    LOOP AT lt_headers INTO ls_header.
      SELECT SINGLE status FROM zorder_status INTO @DATA(lv_stat) WHERE order_id = @ls_header.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
