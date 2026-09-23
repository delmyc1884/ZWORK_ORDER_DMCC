CLASS zcl_work_order_valid_test_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_valid_test_dmcc IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(lo_validator) = NEW zcl_work_order_valid_dmcc( ).

    DATA(lv_valid) = lo_validator->validate_create_order(
      iv_customer_id   = '00000001'
      iv_technician_id = 'TEC00001'
      iv_priority      = 'A'
    ).

    IF lv_valid = abap_true.
      out->write( 'Validacion CREATE correcta.' ).
    ELSE.
      out->write( 'Validacion CREATE incorrecta.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
