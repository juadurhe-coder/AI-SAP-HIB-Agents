CLASS zcl_insecure_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process_vulnerable
      IMPORTING
        iv_table TYPE string
        iv_field TYPE string.
ENDCLASS.

CLASS zcl_insecure_demo IMPLEMENTATION.

  METHOD process_vulnerable.
    DATA: lv_where TYPE string,
          lt_data TYPE TABLE OF string,
          lv_pass TYPE string.

    " 1. Hardcoded Secret
    password = 'MySuperSecretPassword123!'.

    " 2. Dynamic SQL without dyn_prg sanitization
    CONCATENATE 'FIELD = ''' iv_field '''' INTO lv_where.
    SELECT col1 FROM (iv_table) INTO TABLE lt_data WHERE (lv_where).

    " 3. Prohibited Code Injection
    INSERT REPORT 'ZTEST_TEMP' FROM lt_data.

    " 4. DML modification without AUTHORITY-CHECK
    DELETE FROM zcustom_table WHERE id = '100'.

  ENDMETHOD.

ENDCLASS.
