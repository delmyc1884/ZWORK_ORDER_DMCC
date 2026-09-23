CLASS zcl_work_order_auth_test_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_auth_test_dmcc IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    AUTHORITY-CHECK OBJECT 'ZAOWORKDMC'
      ID 'ACTVT' FIELD '03'.

    out->write( |AUTHORITY-CHECK DISPLAY (03): SY-SUBRC = { sy-subrc }| ).

  ENDMETHOD.

ENDCLASS.
