CLASS zcl_work_order_inicio_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_inicio_dmcc IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    "------------------------------------------------------------
    " 1. CLIENTE DE PRUEBA
    "------------------------------------------------------------
    SELECT SINGLE
      FROM ztcustomerdmcc
      FIELDS customer_id
      WHERE customer_id = '00000001'
      INTO @DATA(lv_customer_id).

    IF sy-subrc <> 0.

      INSERT ztcustomerdmcc FROM @( VALUE #(
        customer_id = '00000001'
        name        = 'Joaquin Cruz'
        address     = 'Tegucigalpa'
        phone       = '99999999'
      ) ).

      IF sy-subrc = 0.
        out->write( 'Cliente 00000001 creado correctamente.' ).
      ELSE.
        out->write( 'Error al crear cliente 00000001.' ).
      ENDIF.

    ELSE.
      out->write( 'Cliente 00000001 ya existe.' ).
    ENDIF.


    "------------------------------------------------------------
    " 2. TECNICO DE PRUEBA
    "------------------------------------------------------------
    SELECT SINGLE
      FROM zttechniciandmcc
      FIELDS technician_id
      WHERE technician_id = 'TEC00001'
      INTO @DATA(lv_technician_id).

    IF sy-subrc <> 0.

      INSERT zttechniciandmcc FROM @( VALUE #(
        technician_id = 'TEC00001'
        name          = 'Fernanda Cruz'
        specialty     = 'Redes'
      ) ).

      IF sy-subrc = 0.
        out->write( 'Tecnico TEC00001 creado correctamente.' ).
      ELSE.
        out->write( 'Error al crear tecnico TEC00001.' ).
      ENDIF.

    ELSE.
      out->write( 'Tecnico TEC00001 ya existe.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
