CLASS zcl_work_order_crud_test_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    METHODS test_create_work_order
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    METHODS test_read_work_order
       RETURNING
       VALUE(rs_order) TYPE ztworkorderdmcc.

    METHODS test_update_work_order
       RETURNING
       VALUE(rv_success) TYPE abap_bool.

    METHODS test_delete_work_order
       RETURNING
       VALUE(rv_success) TYPE abap_bool.



ENDCLASS.


CLASS zcl_work_order_crud_test_dmcc IMPLEMENTATION.

  METHOD test_create_work_order.
    DATA(lo_crud) = NEW zcl_work_order_crud_dmcc( ).
    rv_success = lo_crud->create_work_order(
      iv_work_order_id = '0000000001'
      iv_customer_id   = '00000001'
      iv_technician_id = 'TEC00001'
      iv_creation_date = cl_abap_context_info=>get_system_date( )
      iv_status        = 'PE'
      iv_priority      = 'A'
      iv_description   = 'Instalacion de equipo'
    ).
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

  " 1. Crear Orden

  DATA(lv_success) = test_create_work_order( ).

  IF lv_success = abap_true.
    out->write( 'Orden 0000000001 creada correctamente.' ).
  ELSE.
    out->write(
      'La orden no fue creada. Validar datos o existencia previa.'
    ).
  ENDIF.

    " 2. Lectura antes de actualizar

  DATA(ls_order) = test_read_work_order( ).

  IF ls_order-work_order_id IS NOT INITIAL.

    out->write( '--- ORDEN ANTES DEL UPDATE ---' ).
    out->write( |Orden: { ls_order-work_order_id }| ).
    out->write( |Cliente: { ls_order-customer_id }| ).
    out->write( |Tecnico: { ls_order-technician_id }| ).
    out->write( |Fecha: { ls_order-creation_date }| ).
    out->write( |Estado: { ls_order-status }| ).
    out->write( |Prioridad: { ls_order-priority }| ).
    out->write( |Descripcion: { ls_order-description }| ).

  ELSE.

    out->write( 'Orden no encontrada.' ).

  ENDIF.

  " 3. UPDATE

  DATA(lv_update) = test_update_work_order( ).

  IF lv_update = abap_true.
    out->write( 'Orden 0000000001 actualizada correctamente.' ).
  ELSE.
    out->write( 'No fue posible actualizar la orden.' ).
  ENDIF.

  " 4. READ DESPUES DEL UPDATE

  DATA(ls_order_updated) = test_read_work_order( ).

  IF ls_order_updated-work_order_id IS NOT INITIAL.

    out->write( '--- ORDEN DESPUES DEL UPDATE ---' ).
    out->write( |Orden: { ls_order_updated-work_order_id }| ).
    out->write( |Estado: { ls_order_updated-status }| ).
    out->write( |Prioridad: { ls_order_updated-priority }| ).
    out->write(
      |Descripcion: { ls_order_updated-description }|
    ).

  ELSE.

    out->write( 'No se encontro la orden despues del UPDATE.' ).

  ENDIF.

  DATA(lv_delete) = test_delete_work_order( ).

  IF lv_delete = abap_true.
      out->write( 'Orden 0000000001 eliminada correctamente.' ).
   ELSE.
      out->write( 'No fue posible eliminar la orden.' ).
  ENDIF.
  DATA(ls_order_deleted) = test_read_work_order( ).
    IF ls_order_deleted-work_order_id IS INITIAL.
     out->write( 'Verificacion DELETE: la orden ya no existe.' ).
    ELSE.
     out->write( 'Verificacion DELETE: la orden aun existe.' ).
  ENDIF.

ENDMETHOD.

METHOD test_read_work_order.

  DATA(lo_crud) = NEW zcl_work_order_crud_dmcc( ).

  rs_order = lo_crud->read_work_order(
    iv_work_order_id = '0000000001'
  ).

ENDMETHOD.


METHOD test_update_work_order.

  DATA(lo_crud) = NEW zcl_work_order_crud_dmcc( ).

  rv_success = lo_crud->update_work_order(
    iv_work_order_id = '0000000001'
    iv_status        = 'PE'
    iv_priority      = 'B'
    iv_description   = 'Mantenimiento de equipo'
  ).

ENDMETHOD.

METHOD test_delete_work_order.

  DATA(lo_crud) = NEW zcl_work_order_crud_dmcc( ).

  rv_success = lo_crud->delete_work_order(
    iv_work_order_id = '0000000001'
  ).

ENDMETHOD.

ENDCLASS.
