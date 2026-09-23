CLASS zcl_work_order_valid_dmcc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS validate_create_order
      IMPORTING
        iv_customer_id   TYPE zde_customer_id_dmcc
        iv_technician_id TYPE zde_technician_id_dmcc
        iv_priority      TYPE zde_priority_dmcc
      RETURNING
        VALUE(rv_valid)  TYPE abap_bool.

    METHODS validate_update_order
      IMPORTING
        iv_work_order_id TYPE zde_work_order_id_dmcc
        iv_status        TYPE zde_status_dmcc
      RETURNING
        VALUE(rv_valid)  TYPE abap_bool.

     METHODS validate_delete_order
       IMPORTING
         iv_work_order_id TYPE zde_work_order_id_dmcc
         RETURNING
           VALUE(rv_valid)  TYPE abap_bool.

     METHODS validate_status_priority
       IMPORTING
         iv_status       TYPE zde_status_dmcc
         iv_priority     TYPE zde_priority_dmcc
       RETURNING
         VALUE(rv_valid) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_work_order_valid_dmcc IMPLEMENTATION.

  METHOD validate_create_order.

    rv_valid = abap_false.
    IF iv_customer_id IS INITIAL
       OR iv_technician_id IS INITIAL
       OR iv_priority IS INITIAL.

      RETURN.

    ENDIF.

    SELECT SINGLE
      FROM ztcustomerdmcc
      FIELDS customer_id
      WHERE customer_id = @iv_customer_id
      INTO @DATA(lv_customer_id).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE
      FROM zttechniciandmcc
      FIELDS technician_id
      WHERE technician_id = @iv_technician_id
      INTO @DATA(lv_technician_id).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF iv_priority <> 'A'
       AND iv_priority <> 'B'.

      RETURN.

    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_update_order.

  rv_valid = abap_false.
  IF iv_work_order_id IS INITIAL
     OR iv_status IS INITIAL.
    RETURN.
  ENDIF.
  SELECT SINGLE
    FROM ztworkorderdmcc
    FIELDS work_order_id
    WHERE work_order_id = @iv_work_order_id
    INTO @DATA(lv_work_order_id).

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  IF iv_status <> 'PE'.
    RETURN.
  ENDIF.

  rv_valid = abap_true.

ENDMETHOD.

METHOD validate_delete_order.

  rv_valid = abap_false.
  IF iv_work_order_id IS INITIAL.
    RETURN.
  ENDIF.
  SELECT SINGLE
    FROM ztworkorderdmcc
    FIELDS work_order_id
    WHERE work_order_id = @iv_work_order_id
    INTO @DATA(lv_work_order_id).

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  SELECT SINGLE
    FROM ztwrderhistdmcc
    FIELDS history_id
    WHERE work_order_id = @iv_work_order_id
    INTO @DATA(lv_history_id).

  IF sy-subrc = 0.
    RETURN.
  ENDIF.
  rv_valid = abap_true.

ENDMETHOD.

METHOD validate_status_priority.

  rv_valid = abap_false.
  IF iv_status IS INITIAL
     OR iv_priority IS INITIAL.
    RETURN.
  ENDIF.
  IF iv_status <> 'PE'
     AND iv_status <> 'CO'.
    RETURN.
  ENDIF.
  IF iv_priority <> 'A'
     AND iv_priority <> 'B'.
    RETURN.
  ENDIF.
  rv_valid = abap_true.

ENDMETHOD.

ENDCLASS.
