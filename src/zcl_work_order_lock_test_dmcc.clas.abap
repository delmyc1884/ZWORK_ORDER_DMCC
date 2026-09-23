CLASS zcl_work_order_lock_test_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_lock_test_dmcc IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

  DATA lv_work_order_id TYPE zde_work_order_id_dmcc.
  lv_work_order_id = '0000000001'.

  TRY.

      DATA(lo_lock) =
        cl_abap_lock_object_factory=>get_instance(
          iv_name = 'EZWORKDMCC'
        ).

      lo_lock->enqueue(
        it_parameter = VALUE #(
          (
            name  = 'WORK_ORDER_ID'
            value = REF #( lv_work_order_id )
          )
        )
      ).

      out->write(
        |Orden { lv_work_order_id } bloqueada correctamente.|
      ).

    CATCH cx_abap_foreign_lock INTO DATA(lx_foreign).

      out->write(
        |La orden ya esta bloqueada por otra sesion: { lx_foreign->get_text( ) }|
      ).

    CATCH cx_abap_lock_failure INTO DATA(lx_lock).

      out->write(
        |Error al realizar el bloqueo: { lx_lock->get_text( ) }|
      ).

  ENDTRY.

ENDMETHOD.

ENDCLASS.
