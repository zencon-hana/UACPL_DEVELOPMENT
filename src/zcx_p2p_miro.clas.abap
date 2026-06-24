CLASS zcx_p2p_miro DEFINITION INHERITING FROM cx_static_check
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF c_generic_error,
        msgid TYPE symsgid VALUE 'ZMIRO_MSG',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'IV_FIELD1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF c_generic_error,

      BEGIN OF cs_data_error,
        msgid TYPE symsgid VALUE 'ZMIRO_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF cs_data_error,

      BEGIN OF cs_taxcode_prcnt_not_found,
        msgid TYPE symsgid VALUE 'ZMIRO_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'IV_FIELD1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF cs_taxcode_prcnt_not_found .

    DATA: md_error  TYPE sysubrc,
          mv_field1 TYPE string,
          mv_field2 TYPE string,
          mv_field3 TYPE string,
          mv_field4 TYPE string.

    METHODS constructor
      IMPORTING
        !textid    LIKE if_t100_message=>t100key  OPTIONAL
        !previous  LIKE previous OPTIONAL
        !id_error  TYPE sysubrc OPTIONAL
        !iv_field1 TYPE string OPTIONAL
        !iv_field2 TYPE string OPTIONAL
        !iv_field3 TYPE string OPTIONAL
        !iv_field4 TYPE string OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_P2P_MIRO IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = cs_data_error.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
    if iv_field1 is NOT INITIAL.
      if_t100_message~t100key-attr1 = iv_field1.
    endif.
    if iv_field2 is NOT INITIAL.
      if_t100_message~t100key-attr2 = iv_field2.
    endif.
    if iv_field3 is NOT INITIAL.
      if_t100_message~t100key-attr3 = iv_field3.
    endif.
    if iv_field4 is NOT INITIAL.
      if_t100_message~t100key-attr4 = iv_field4.
    endif.

    md_error = id_error.
    mv_field1 = iv_field1.
    mv_field2 = iv_field2.
    mv_field3 = iv_field3.
    mv_field4 = iv_field4.
  ENDMETHOD.
ENDCLASS.
