CLASS zcl_api_usr_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: get_url RETURNING VALUE(rv_url) TYPE string
                           RAISING   cx_abap_context_info_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_API_USR_UTILITY IMPLEMENTATION.


  METHOD get_url.
    DATA(lv_cotx_url) = cl_abap_context_info=>get_system_url( ).
    CONCATENATE 'https://' lv_cotx_url ':443' INTO DATA(lv_url)  .
    rv_url = lv_url.
  ENDMETHOD.
ENDCLASS.
