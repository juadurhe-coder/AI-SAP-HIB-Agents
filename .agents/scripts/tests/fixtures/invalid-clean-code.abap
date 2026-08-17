CLASS zcl_legacy_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Declaracion de variables
    METHODS execute_legacy
      IMPORTING
        p1 TYPE i
        p2 TYPE i
        p3 TYPE i
        p4 TYPE i
        p5 TYPE i
        p6 TYPE i.
ENDCLASS.

CLASS zcl_legacy_demo IMPLEMENTATION.

  METHOD execute_legacy.
    * IF sy-subrc = 0.
    *   MOVE p1 TO p2.
    * ENDIF.

    DATA: my_data_table TYPE TABLE OF string,
          lo_client TYPE REF TO zcl_legacy_demo.
    FIELD-SYMBOLS: <record> TYPE string.

    " Clean Core violation
    SUBMIT zreport_batch AND RETURN.
    OPEN DATASET 'file.txt' FOR INPUT IN TEXT MODE.

    " Magic number & literal
    IF p1 = 'ABCDE'.
      IF p2 = 99.
        IF p3 = 10.
          IF p4 = 20.
            p5 = 30.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    " Robustness: Unassigned Field Symbol & unbound object call
    <record>-value = 'ERROR'.
    lo_client->execute_legacy( p1 = 1 p2 = 2 p3 = 3 p4 = 4 p5 = 5 p6 = 6 ).

  ENDMETHOD.

ENDCLASS.
