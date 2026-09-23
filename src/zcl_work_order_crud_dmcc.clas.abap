CLASS zcl_work_order_crud_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  TYPES ty_t_work_orders TYPE STANDARD TABLE OF ztworkorderdmcc
  WITH EMPTY KEY.

  METHODS create_work_order
     IMPORTING
       iv_work_order_id TYPE zde_work_order_id_dmcc
       iv_customer_id   TYPE zde_customer_id_dmcc
       iv_technician_id TYPE zde_technician_id_dmcc
       iv_creation_date TYPE ztworkorderdmcc-creation_date
       iv_status        TYPE zde_status_dmcc
       iv_priority      TYPE zde_priority_dmcc
        iv_description TYPE ztworkorderdmcc-description
     RETURNING
        VALUE(rv_success) TYPE abap_bool.

   METHODS read_work_order
     IMPORTING
       iv_work_order_id TYPE zde_work_order_id_dmcc
     RETURNING
        VALUE(rs_order) TYPE ztworkorderdmcc.

    METHODS update_work_order
       IMPORTING
          iv_work_order_id TYPE zde_work_order_id_dmcc
          iv_status        TYPE zde_status_dmcc
          iv_priority      TYPE zde_priority_dmcc
          iv_description   TYPE ztworkorderdmcc-description
       RETURNING
          VALUE(rv_success) TYPE abap_bool.

    METHODS delete_work_order
      IMPORTING
         iv_work_order_id TYPE zde_work_order_id_dmcc
      RETURNING
       VALUE(rv_success) TYPE abap_bool.

    METHODS read_work_orders
      IMPORTING
        iv_customer_id TYPE zde_customer_id_dmcc OPTIONAL
        iv_status      TYPE zde_status_dmcc OPTIONAL
        iv_date_from   TYPE ztworkorderdmcc-creation_date OPTIONAL
        iv_date_to     TYPE ztworkorderdmcc-creation_date OPTIONAL
      RETURNING
        VALUE(rt_orders) TYPE ty_t_work_orders.



  PROTECTED SECTION.

   METHODS add_history
     IMPORTING
       iv_work_order_id      TYPE zde_work_order_id_dmcc
       iv_change_description TYPE ztwrderhistdmcc-change_description.
   PRIVATE SECTION.


ENDCLASS.

CLASS zcl_work_order_crud_dmcc IMPLEMENTATION.
METHOD create_work_order.
  rv_success = abap_false.
  IF iv_work_order_id IS INITIAL.
    RETURN.
  ENDIF.
  DATA(lo_validator) = NEW zcl_work_order_valid_dmcc( ).
  DATA(lv_valid_create) = lo_validator->validate_create_order(
    iv_customer_id   = iv_customer_id
    iv_technician_id = iv_technician_id
    iv_priority      = iv_priority
  ).

  IF lv_valid_create = abap_false.
    RETURN.
  ENDIF.
  DATA(lv_valid_status) = lo_validator->validate_status_priority(
    iv_status   = iv_status
    iv_priority = iv_priority
  ).

  IF lv_valid_status = abap_false.
    RETURN.
  ENDIF.

  SELECT SINGLE
    FROM ztworkorderdmcc
    FIELDS work_order_id
    WHERE work_order_id = @iv_work_order_id
    INTO @DATA(lv_existing_order).
  IF sy-subrc = 0.
    RETURN.
  ENDIF.
  INSERT ztworkorderdmcc FROM @( VALUE #(
    work_order_id = iv_work_order_id
    customer_id   = iv_customer_id
    technician_id = iv_technician_id
    creation_date = iv_creation_date
    status        = iv_status
    priority      = iv_priority
    description   = iv_description
  ) ).

  IF sy-subrc = 0.
    rv_success = abap_true.
  ENDIF.
ENDMETHOD.

METHOD read_work_order.

  CLEAR rs_order.

  IF iv_work_order_id IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE
    FROM ztworkorderdmcc
    FIELDS *
    WHERE work_order_id = @iv_work_order_id
    INTO @rs_order.

ENDMETHOD.

METHOD update_work_order.

  rv_success = abap_false.

  DATA(lo_validator) = NEW zcl_work_order_valid_dmcc( ).
  DATA(lv_valid_update) = lo_validator->validate_update_order(
    iv_work_order_id = iv_work_order_id
    iv_status        = iv_status
  ).

  IF lv_valid_update = abap_false.
    RETURN.
  ENDIF.
  DATA(lv_valid_values) = lo_validator->validate_status_priority(
    iv_status   = iv_status
    iv_priority = iv_priority
  ).

  IF lv_valid_values = abap_false.
    RETURN.
  ENDIF.
  DATA(lv_work_order_id) = iv_work_order_id.

   DATA(lo_lock) =
       cl_abap_lock_object_factory=>get_instance(
        iv_name = 'EZWORKDMCC'
        ).
   TRY.

    lo_lock->enqueue(
      it_parameter = VALUE #(
        ( name  = 'WORK_ORDER_ID'
          value = REF #( lv_work_order_id ) )
      )
    ).

  CATCH cx_abap_foreign_lock.
    RETURN.

  CATCH cx_abap_lock_failure.
    RETURN.



ENDTRY.

  UPDATE ztworkorderdmcc
    SET status      = @iv_status,
        priority    = @iv_priority,
        description = @iv_description
    WHERE work_order_id = @iv_work_order_id.

   IF sy-subrc = 0.
      add_history(
        iv_work_order_id      = iv_work_order_id
        iv_change_description = 'Orden de trabajo actualizada'
      ).
    rv_success = abap_true.
   ENDIF.

TRY.

    lo_lock->dequeue( ).

  CATCH cx_abap_lock_failure.


ENDTRY.
ENDMETHOD.

METHOD delete_work_order.

  rv_success = abap_false.

  DATA(lo_validator) = NEW zcl_work_order_valid_dmcc( ).

  DATA(lv_valid_delete) = lo_validator->validate_delete_order(
    iv_work_order_id = iv_work_order_id
  ).

  IF lv_valid_delete = abap_false.
    RETURN.
  ENDIF.

  SELECT SINGLE
    FROM ztworkorderdmcc
    FIELDS status
    WHERE work_order_id = @iv_work_order_id
    INTO @DATA(lv_status).

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF lv_status <> 'PE'.
    RETURN.
  ENDIF.

  DELETE FROM ztworkorderdmcc
    WHERE work_order_id = @iv_work_order_id.

  IF sy-subrc = 0.
    rv_success = abap_true.
  ENDIF.

ENDMETHOD.

METHOD add_history.

  SELECT MAX( history_id )
    FROM ztwrderhistdmcc
    INTO @DATA(lv_max_history_id).

  DATA(lv_history_id) = CONV ztwrderhistdmcc-history_id(
    CONV int8( lv_max_history_id ) + 1
  ).

  INSERT ztwrderhistdmcc FROM @( VALUE #(
    history_id         = lv_history_id
    work_order_id      = iv_work_order_id
    modification_date  = cl_abap_context_info=>get_system_date( )
    change_description = iv_change_description
  ) ).

ENDMETHOD.

METHOD read_work_orders.

  SELECT
    FROM ztworkorderdmcc
    FIELDS *
    WHERE ( @iv_customer_id IS INITIAL
            OR customer_id = @iv_customer_id )
      AND ( @iv_status IS INITIAL
            OR status = @iv_status )
      AND ( @iv_date_from IS INITIAL
            OR creation_date >= @iv_date_from )
      AND ( @iv_date_to IS INITIAL
            OR creation_date <= @iv_date_to )
    INTO TABLE @rt_orders.

ENDMETHOD.

ENDCLASS.
