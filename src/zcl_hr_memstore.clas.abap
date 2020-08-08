class ZCL_HR_MEMSTORE definition
  public
  final
  create public .

public section.

  class-methods ADD
    importing
      !K type STRING
      !V type STRING .
  class-methods GET
    importing
      !K type STRING
    returning
      value(V) type STRING .
  class-methods LOAD
    importing
      !I_DATA type THEAD-TDNAME .
  class-methods INIT .
protected section.
private section.

  types:
    begin of TY_STORE,
    k type STRING,
    v type string,
    end of ty_store .
  types:
*    TY_STORE_TAB type standard table of ty_store ,
    TY_STORE_TAB type hashed table of ty_store with UNIQUE KEY k.

  class-data DS type TY_STORE_TAB .
ENDCLASS.



CLASS ZCL_HR_MEMSTORE IMPLEMENTATION.


  METHOD ADD.

    data new_rec type ty_store.

    READ TABLE ds ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY k = k.
    IF sy-subrc EQ 0.
      <fs>-v = v.
    ELSE.
*      APPEND INITIAL LINE TO ds ASSIGNING <fs>.
*      <fs>-k = k.
*      <fs>-v = v.
      new_rec-k = k.
      new_rec-v = v.
      insert new_rec into table ds.
    ENDIF.

  ENDMETHOD.


  METHOD GET.

    READ TABLE ds ASSIGNING FIELD-SYMBOL(<fs>) WITH KEY k = k.
    IF sy-subrc EQ 0.
      v = <fs>-v.
    ELSE.
      CLEAR v.
    ENDIF.

  ENDMETHOD.


  METHOD init.
    FREE ds.
  ENDMETHOD.


  METHOD LOAD.

    DATA lt_tline        TYPE STANDARD TABLE OF tline.
    DATA l_object        TYPE thead-tdobject VALUE 'TEXT'.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = 'ST'
        language = sy-langu
        name     = i_data
        object   = l_object
      TABLES
        lines    = lt_tline
      EXCEPTIONS
        OTHERS   = 4.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA: l_key   TYPE string,
          l_value TYPE string,
          l_d TYPE string.

    LOOP AT lt_tline ASSIGNING FIELD-SYMBOL(<fs>).
      IF strlen( <fs>-tdline ) > 1.
        IF <fs>-tdline+0(1) NE '#'.
          IF <fs>-tdline CS '='.
            SPLIT <fs>-tdline AT '=' INTO l_key l_value l_d.
            add( k = l_key
                 v = l_value ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
