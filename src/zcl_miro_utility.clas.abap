CLASS zcl_miro_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

    TYPES: tyt_zc_miro   TYPE TABLE OF zc_miro,
           tyt_park_keys TYPE TABLE FOR ACTION IMPORT zc_miro~parkinvoice,
           tyt_post_keys TYPE TABLE FOR ACTION IMPORT zc_miro~parkinvoice,
           tys_park_keys TYPE LINE OF tyt_park_keys,
           tys_post_keys TYPE LINE OF tyt_park_keys,

           BEGIN OF tys_park_msg,
             keys    TYPE tys_park_keys,
             msgtyp  TYPE  c LENGTH 1,
             message TYPE string,
           END OF tys_park_msg,

           tyt_park_msg TYPE STANDARD TABLE OF tys_park_msg WITH DEFAULT KEY.

    TYPES: tyt_soi_deep_create  TYPE STANDARD TABLE OF zapi_supplierinvoice_process=>tys_a_suplr_invc_item_pur_or_2 WITH NON-UNIQUE DEFAULT KEY,
           tyt_whld_deep_create TYPE STANDARD TABLE OF zapi_supplierinvoice_process=>tys_a_suplr_invc_header_whld_2 WITH NON-UNIQUE DEFAULT KEY,
           BEGIN OF tys_deep_create.
             INCLUDE TYPE zapi_supplierinvoice_process=>tys_a_supplier_invoice_type AS header.
    TYPES: to_suplr_invc_item_pur_ord TYPE tyt_soi_deep_create,
             to_supplier_invoice_whldg  TYPE tyt_whld_deep_create,
           END OF tys_deep_create,
           tyv_amt     TYPE p LENGTH 13 DECIMALS 2,
           tys_item_no TYPE n LENGTH 6.

    TYPES : BEGIN OF tys_output_msg,
              keys             TYPE TABLE FOR ACTION IMPORT zc_miro~parkinvoice,
              msgtyp           TYPE  c LENGTH 1,
              supplier_invoice TYPE i_supplierinvoicetp-supplierinvoice,
              year             TYPE i_supplierinvoicetp-supplierinvoicefiscalyear,
              msg              TYPE string,
              zc_miro          TYPE zc_miro,
            END OF tys_output_msg.
    TYPES: tyt_output_msg            TYPE STANDARD TABLE OF tys_output_msg WITH DEFAULT KEY,
           tyv_supplierinvoicestatus TYPE c LENGTH 1,
           tyt_string                TYPE STANDARD TABLE OF string WITH NON-UNIQUE DEFAULT KEY.

    DATA: mt_output_msg      TYPE tyt_output_msg.

    DATA: mt_zc_miro            TYPE tyt_zc_miro,
          mv_user_post_dt       TYPE budat,
          mv_user_documnt_dt    TYPE bldat,
          mv_grp_by             TYPE zd_p2p_miro_collective_by,
          mv_new_reference_no   TYPE zrk_a_miro_park_in-new_reference_no,
          mv_user_inv_gross_amt TYPE zrk_a_miro_park_in-usr_choice_inv_gross_amt,
          mo_client_proxy       TYPE REF TO /iwbep/if_cp_client_proxy.

    CONSTANTS: BEGIN OF cs_collective_by,
                 gn TYPE zd_p2p_miro_collective_by VALUE 'GN',
                 po TYPE zd_p2p_miro_collective_by VALUE 'PO',
               END OF cs_collective_by,

               BEGIN OF cs_doc_ref_type,
                 grn TYPE string VALUE 'GRN no',
                 po  TYPE string VALUE 'PO no',
               END OF cs_doc_ref_type,

               cv_tolerance_amt TYPE tyv_amt VALUE '3'.

    METHODS :
      constructor IMPORTING it_zc_miro            TYPE tyt_zc_miro
                            iv_user_post_dt       TYPE budat      OPTIONAL
                            iv_user_documnt_dt    TYPE bldat      OPTIONAL
                            iv_new_reference_no   TYPE zrk_a_miro_park_in-new_reference_no OPTIONAL
                            iv_user_inv_gross_amt TYPE zrk_a_miro_park_in-usr_choice_inv_gross_amt OPTIONAL
                            iv_grp_by             TYPE zd_p2p_miro_collective_by OPTIONAL,

      park_invoice RETURNING VALUE(rt_park_msg) TYPE tyt_park_msg RAISING zcx_p2p_miro,
      post_invoice RETURNING VALUE(rt_park_msg) TYPE tyt_park_msg RAISING zcx_p2p_miro.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS : build_communication_with_api RAISING zcx_p2p_miro,
      buid_businessdata IMPORTING iv_supplierinvoicestatus TYPE tyv_supplierinvoicestatus
                        RAISING   zcx_p2p_miro,
      buid_posting_businessdata RAISING   zcx_p2p_miro,
      get_gross_amount IMPORTING is_zc_miro                TYPE zc_miro
                       RETURNING VALUE(rv_in_gross_amount) TYPE tyv_amt
                       RAISING   zcx_p2p_miro,

      get_tan_tax_amount IMPORTING is_zc_miro                  TYPE zc_miro
                         RETURNING VALUE(rv_in_tan_tax_amount) TYPE tyv_amt
                         RAISING   zcx_p2p_miro,

      park_miro_api IMPORTING iv_ref_id        TYPE string
                              iv_ref_doc_type  TYPE string
                              is_deep_data_new TYPE tys_deep_create
                              it_zc_miro       TYPE tyt_zc_miro
                    RAISING   zcx_p2p_miro,

      prepare_header_properties RETURNING VALUE(rs_header_prpty) TYPE tyt_string,

      prepare_items_properties RETURNING VALUE(rs_item_prpty) TYPE tyt_string,
      prepare_withhold_properties RETURNING VALUE(rs_item_prpty) TYPE tyt_string,

      prepare_header_data IMPORTING iv_inv_gross_amount            TYPE tyv_amt
                                    iv_supplierinvoicestatus       TYPE zcl_miro_utility=>tyv_supplierinvoicestatus
                                    is_zc_miro                     TYPE zc_miro
                                    is_highest_posting_date        TYPE datum OPTIONAL
                          RETURNING VALUE(rs_header_business_data) TYPE zapi_supplierinvoice_process=>tys_a_supplier_invoice_type,

      prepare_items_data IMPORTING iv_item_no                TYPE tys_item_no
                                   is_zc_miro                TYPE zc_miro
                         RETURNING VALUE(rs_soi_deep_create) TYPE zapi_supplierinvoice_process=>tys_a_suplr_invc_item_pur_or_2,

      prepare_withhold_tax_data IMPORTING is_zc_miro                 TYPE zc_miro
                                          iv_withhold_amt            TYPE tyv_amt
                                RETURNING VALUE(rs_whld_deep_create) TYPE zapi_supplierinvoice_process=>tys_a_suplr_invc_header_whld_2,

      choose_gross_amt IMPORTING iv_inv_gross_amount        TYPE tyv_amt
                       RETURNING VALUE(rv_inv_gross_amount) TYPE tyv_amt
                       RAISING   zcx_p2p_miro.

ENDCLASS.



CLASS ZCL_MIRO_UTILITY IMPLEMENTATION.


  METHOD buid_businessdata.
    DATA: ls_header_business_data  TYPE zapi_supplierinvoice_process=>tys_a_supplier_invoice_type,
          ls_deep_data_new         TYPE tys_deep_create,
*          ls_business_data_poref  TYPE ZAPI_SUPPLIERINVOICE_PROCESS=>tys_a_suplr_invc_item_pur_or_2,
          lo_http_client           TYPE REF TO if_web_http_client,
          lt_item_business_data    TYPE tyt_soi_deep_create,
          lt_with_hold_data        TYPE tyt_whld_deep_create,
          lv_inv_gross_amount      TYPE tyv_amt,
          lv_in_tan_tax_amount     TYPE tyv_amt,
          lv_in_tan_tax_amount_col TYPE tyv_amt,
          lv_in_po_base_amount     TYPE tyv_amt,
          lv_highest_materialdocno TYPE zc_miro-MaterialDocument,
          lv_item_no               TYPE tys_item_no,
          lt_miro_members          TYPE TABLE OF zc_miro,
          lv_highest_posting_dt    TYPE datum.

    IF mv_grp_by IS INITIAL.
      mv_grp_by = cs_collective_by-gn.
    ENDIF.

    CASE mv_grp_by.
      WHEN cs_collective_by-gn.

        LOOP AT mt_zc_miro ASSIGNING FIELD-SYMBOL(<ls_grn>)
        GROUP BY ( materialdocument = <ls_grn>-materialdocument
                   materialyear = <ls_grn>-materialdocumentyear
                   size = GROUP SIZE
                   index = GROUP INDEX )
        ASCENDING
        REFERENCE INTO DATA(lo_miro_grn).

          LOOP AT GROUP lo_miro_grn ASSIGNING FIELD-SYMBOL(<ls_grp_members>).
*            lv_highest_posting_dt = COND #( WHEN lv_highest_posting_dt < <ls_grp_members>-PostingDate THEN <ls_grp_members>-PostingDate ELSE lv_highest_posting_dt ).
            lv_in_po_base_amount += <ls_grp_members>-purchaseorderamount.
            lv_inv_gross_amount += get_gross_amount( <ls_grp_members> ).
            lv_in_tan_tax_amount = get_tan_tax_amount( <ls_grp_members> ).
*            lv_inv_gross_amount = ( lv_inv_gross_amount - lv_in_tan_tax_amount ) .
            lv_in_tan_tax_amount_col += lv_in_tan_tax_amount.
            lv_item_no += 1.
            lt_item_business_data = VALUE #( BASE lt_item_business_data ( me->prepare_items_data( iv_item_no = lv_item_no is_zc_miro = <ls_grp_members> ) ) ).
            APPEND <ls_grp_members> TO lt_miro_members.
          ENDLOOP.
          lt_with_hold_data = VALUE tyt_whld_deep_create( ( me->prepare_withhold_tax_data( is_zc_miro = <ls_grp_members> iv_withhold_amt = lv_in_tan_tax_amount_col ) ) ).
          ls_header_business_data  = prepare_header_data( iv_supplierinvoicestatus = iv_supplierinvoicestatus
                                                          iv_inv_gross_amount = choose_gross_amt( iv_inv_gross_amount = lv_inv_gross_amount )
                                                          is_zc_miro = <ls_grp_members> ).
*                                                          is_highest_posting_date = lv_highest_posting_dt

          ls_deep_data_new = CORRESPONDING #( ls_header_business_data ).
          ls_deep_data_new-to_suplr_invc_item_pur_ord = lt_item_business_data.
          ls_deep_data_new-to_supplier_invoice_whldg = lt_with_hold_data.

          park_miro_api( iv_ref_id = CONV #( <ls_grp_members>-materialdocument )
                         iv_ref_doc_type = cs_doc_ref_type-grn
                         is_deep_data_new = ls_deep_data_new
                         it_zc_miro = lt_miro_members ).

          CLEAR: lv_inv_gross_amount,
                 lv_in_tan_tax_amount,
                 lv_in_po_base_amount,
                 lv_in_tan_tax_amount_col,
                 lv_highest_posting_dt,
                 lv_highest_materialdocno,
                 lv_item_no,
                 ls_deep_data_new,
                 lt_miro_members[],
                 lt_with_hold_data[],
                 lt_item_business_data[].
        ENDLOOP.

      WHEN cs_collective_by-po.

        LOOP AT mt_zc_miro ASSIGNING FIELD-SYMBOL(<ls_po>)
        GROUP BY ( purchaseorder = <ls_po>-purchaseorder )
*                   PurchaseOrderItem = <ls_po>-PurchaseOrderItem )
        ASCENDING
        REFERENCE INTO DATA(lo_miro_po).

          LOOP AT GROUP lo_miro_po ASSIGNING <ls_grp_members>.
*            lv_highest_posting_dt = COND #( WHEN lv_highest_posting_dt < <ls_grp_members>-PostingDate THEN <ls_grp_members>-PostingDate ELSE lv_highest_posting_dt ).
            IF lv_highest_materialdocno <= <ls_grp_members>-MaterialDocument.
              lv_highest_materialdocno = <ls_grp_members>-MaterialDocument.
              lv_highest_posting_dt = <ls_grp_members>-PostingDate.
            ENDIF.
            lv_in_po_base_amount += <ls_grp_members>-purchaseorderamount.
            lv_inv_gross_amount += get_gross_amount( <ls_grp_members> ).
            lv_in_tan_tax_amount = get_tan_tax_amount( <ls_grp_members> ).
*            lv_inv_gross_amount = ( lv_inv_gross_amount - lv_in_tan_tax_amount ).
            lv_in_tan_tax_amount_col += lv_in_tan_tax_amount.
            lv_item_no += 1.
            lt_item_business_data = VALUE #( BASE lt_item_business_data ( me->prepare_items_data( iv_item_no = lv_item_no is_zc_miro = <ls_grp_members> ) ) ).
            APPEND <ls_grp_members> TO lt_miro_members.

          ENDLOOP.
          lt_with_hold_data = VALUE tyt_whld_deep_create( ( me->prepare_withhold_tax_data( is_zc_miro = <ls_grp_members> iv_withhold_amt = lv_in_tan_tax_amount_col ) ) ).

          ls_header_business_data  = prepare_header_data( iv_supplierinvoicestatus = iv_supplierinvoicestatus
                                                          iv_inv_gross_amount = choose_gross_amt( iv_inv_gross_amount = lv_inv_gross_amount )
                                                          is_zc_miro = <ls_grp_members>
                                                          is_highest_posting_date = lv_highest_posting_dt ).

          ls_deep_data_new = CORRESPONDING #( ls_header_business_data ).
          ls_deep_data_new-to_suplr_invc_item_pur_ord = lt_item_business_data.
          ls_deep_data_new-to_supplier_invoice_whldg = lt_with_hold_data.

          park_miro_api( iv_ref_id = CONV #( <ls_grp_members>-purchaseorder )
                         iv_ref_doc_type = cs_doc_ref_type-po
                         is_deep_data_new = ls_deep_data_new
                         it_zc_miro = lt_miro_members ).

          CLEAR: lv_inv_gross_amount,
                 lv_in_tan_tax_amount,
                 lv_in_po_base_amount,
                 lv_in_tan_tax_amount_col,
                 lv_item_no,
                 lv_highest_posting_dt,
                 lv_highest_materialdocno,
                 ls_deep_data_new,
                 lt_miro_members[],
                 lt_with_hold_data[],
                 lt_item_business_data[].
        ENDLOOP.

*      WHEN OTHERS. "Considered under collective GRN
*        LOOP AT mt_zc_miro ASSIGNING FIELD-SYMBOL(<ls_zc_miro>).
*          lv_inv_gross_amount = get_gross_amount( <ls_zc_miro> ).
*          lv_in_tan_tax_amount = get_tan_tax_amount( <ls_zc_miro> ).
**          lv_inv_gross_amount = ( lv_inv_gross_amount - lv_in_tan_tax_amount ).
*
*          ls_header_business_data  = prepare_header_data( iv_supplierinvoicestatus = iv_supplierinvoicestatus
*                                                          iv_inv_gross_amount = choose_gross_amt( iv_inv_gross_amount = lv_inv_gross_amount )
*                                                          is_zc_miro = <ls_zc_miro> ).
*
*          lt_item_business_data = VALUE tyt_soi_deep_create( ( me->prepare_items_data( iv_item_no = '00001' is_zc_miro = <ls_zc_miro> ) ) ).
*
*          lt_with_hold_data = VALUE tyt_whld_deep_create( ( me->prepare_withhold_tax_data( is_zc_miro = <ls_zc_miro> iv_withhold_amt = lv_in_tan_tax_amount ) ) ).
*          ls_deep_data_new = CORRESPONDING #( ls_header_business_data ).
*          ls_deep_data_new-to_suplr_invc_item_pur_ord = lt_item_business_data.
*          ls_deep_data_new-to_supplier_invoice_whldg = lt_with_hold_data.
*          park_miro_api( iv_ref_id = CONV #( <ls_zc_miro>-purchaseorder )
*                         iv_ref_doc_type  = cs_doc_ref_type-po
*                         is_deep_data_new = ls_deep_data_new
*                         it_zc_miro       = VALUE #( ( <ls_zc_miro> ) )  ).
*        ENDLOOP.
    ENDCASE.

  ENDMETHOD.


  METHOD buid_posting_businessdata.
    TYPES : BEGIN OF tys_parameter,
              name  TYPE string,
              value TYPE string,
            END OF tys_parameter,
            BEGIN OF tys_response_data,
              success TYPE string,
            END OF tys_response_data.
    DATA: ls_post_parameter TYPE zapi_supplierinvoice_process=>tys_parameters_2,
          ls_response_data  TYPE tys_response_data.

    LOOP AT mt_zc_miro ASSIGNING FIELD-SYMBOL(<ls_zc_miro>).
      TRY.
          DATA(lo_request) = mo_client_proxy->create_resource_for_function( zapi_supplierinvoice_process=>gcs_function_import-post ).
          lo_request->set_parameter(
            EXPORTING
              is_parameter = VALUE zapi_supplierinvoice_process=>tys_parameters_2( supplier_invoice = <ls_zc_miro>-supplierinvoice
                                                                                   fiscal_year      = <ls_zc_miro>-fiscalyear ) ).

          " Execute the request
          DATA(lo_response) = lo_request->create_request( ).

          " Get the after image
          DATA(lo_res) = lo_response->execute( 'POST' ).
          lo_res->get_business_data(
            IMPORTING
              ea_response_data = ls_response_data
          ).
*          CATCH /iwbep/cx_gateway.
        CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
          DATA(lv_error) = lx_remote->http_error_body.
          DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
          DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
        CATCH  /iwbep/cx_gateway INTO DATA(lx_gateway).
          lv_error2 = lx_gateway->get_text( ).
        CATCH cx_root INTO DATA(lx_root).
          lv_error2 = lx_root->get_text( ).
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
      ENDTRY.

      IF ls_response_data IS NOT INITIAL.
        DATA(lv_success_msg) = |{ <ls_zc_miro>-supplierinvoice } fiscal { <ls_zc_miro>-fiscalyear } posted | .
      ELSE.
        DATA(lv_fail_msg) = |Failed Note { lv_error2 } |.
      ENDIF.
      mt_output_msg = VALUE #( BASE mt_output_msg ( keys             = VALUE #( ( %key = VALUE #( purchaseorder = <ls_zc_miro>-purchaseorder
                                                                                                  purchaseorderitem = <ls_zc_miro>-purchaseorderitem
                                                                                                  accountassignmentnumber = <ls_zc_miro>-accountassignmentnumber
                                                                                                  purchasinghistorydocument = <ls_zc_miro>-purchasinghistorydocument
                                                                                                  purchasinghistorydocumentitem = <ls_zc_miro>-purchasinghistorydocumentitem
                                                                                                  purchasinghistorydocumenttype = <ls_zc_miro>-purchasinghistorydocumenttype
                                                                                                  purchasinghistorydocumentyear = <ls_zc_miro>-purchasinghistorydocumentyear
                                                                                                  supplierinvoice = <ls_zc_miro>-supplierinvoice
                                                                                                  fiscalyear = <ls_zc_miro>-fiscalyear
                                                                                                  WithholdingTaxCode = <ls_zc_miro>-WithholdingTaxCode
                                                                                                  WithholdingTaxType = <ls_zc_miro>-WithholdingTaxType ) ) )
                                                    supplier_invoice = <ls_zc_miro>-supplierinvoice
                                                    year             = <ls_zc_miro>-fiscalyear
                                                    msgtyp           = COND #( WHEN ls_response_data IS NOT INITIAL THEN 'S' ELSE 'E' )
                                                    msg              = COND #( WHEN ls_response_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD build_communication_with_api.
    DATA: lo_http_client TYPE REF TO if_web_http_client.

    TRY.
        SELECT SINGLE * FROM zc_api_usr
        WHERE ApiUser = @zif_apis=>c_api_custom_credentials-username
        INTO @DATA(ls_zc_api_usr).
*        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                      EXPORTING
*                                        comm_scenario      = 'ZCOM_ARRANGE_API'
**                                        service_id         = 'API_SUPPLIERINVOICE_PROC_SRV_0001_IWSG'
**                                       comm_system_id     = 'BACKEND_CON'
*                                        ).
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( i_url = zcl_api_usr_utility=>get_url( ) ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        lo_http_client->get_http_request( )->set_authorization_basic(
          EXPORTING
            i_username = CONV #( ls_zc_api_usr-ApiUser )
            i_password = CONV #( ls_zc_api_usr-Password )
        ).

*        DATA(lo_http_client) =  cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_client_proxy) = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
                                  EXPORTING
                                    is_proxy_model_key       =  VALUE #( repository_id = 'DEFAULT'
                                                                         proxy_model_id = 'ZAPI_SUPPLIERINVOICE_PROCESS'  "'API_SUPPLIERINVOICE_PROC_SRV_0001_IWSG'
                                                                         proxy_model_version = '0001' )
                                    io_http_client           = lo_http_client
                                    iv_relative_service_root = zif_apis=>c_url-supplier_invoice "'/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV'
*                                        iv_do_fetch_csrf_token   = abap_true
                                ).
        mo_client_proxy = lo_client_proxy.

      CATCH cx_root INTO DATA(lx_root).
        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
    ENDTRY.

  ENDMETHOD.


  METHOD choose_gross_amt.

    IF mv_user_inv_gross_amt IS INITIAL.
      rv_inv_gross_amount = iv_inv_gross_amount.
    ELSE.
      "check tolerance ( upto 3 rupees )
      IF mv_user_inv_gross_amt <= ( iv_inv_gross_amount + cv_tolerance_amt ) AND
         mv_user_inv_gross_amt >= ( iv_inv_gross_amount - cv_tolerance_amt ).
        rv_inv_gross_amount = mv_user_inv_gross_amt.
      ELSE.
        "Raise error on rounding fail.
        RAISE EXCEPTION NEW zcx_p2p_miro( textid = VALUE #( msgid = 'ZMIRO_MSG'
                                                             msgno = '006'
                                                             attr1 = ( iv_inv_gross_amount - cv_tolerance_amt )
                                                             attr2 = ( iv_inv_gross_amount + cv_tolerance_amt ) ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    mt_zc_miro = it_zc_miro.
    mv_user_post_dt = iv_user_post_dt.
    mv_user_documnt_dt = iv_user_documnt_dt.
    mv_new_reference_no = iv_new_reference_no.
    mv_grp_by = iv_grp_by.
    mv_user_inv_gross_amt = iv_user_inv_gross_amt.
  ENDMETHOD.


  METHOD get_gross_amount.
    DATA : lv_gross_amount TYPE p DECIMALS 2.

    SELECT SINGLE * FROM zz1_tax_code1 WHERE tax_code = @is_zc_miro-taxcode INTO @DATA(ls_taxes).
    IF sy-subrc = 0.
      rv_in_gross_amount = is_zc_miro-purchaseorderamount * ( 100 + ls_taxes-cgst + ls_taxes-sgst + ls_taxes-igst ) / 100 .
    ELSE.
*      rv_in_gross_amount = is_zc_miro-purchaseorderamount * '1.18'.
*      RETURN.
      RAISE EXCEPTION NEW zcx_p2p_miro( textid    = zcx_p2p_miro=>cs_taxcode_prcnt_not_found
                                        iv_field1 = CONV #( is_zc_miro-taxcode ) ).
    ENDIF.
  ENDMETHOD.


  METHOD get_tan_tax_amount.
    CONSTANTS : lc_point_1_percent TYPE p LENGTH 5 DECIMALS 2 VALUE '0.1'.
    IF is_zc_miro-in_thresholdamountdiff >= is_zc_miro-purchaseorderamount.
      RETURN. "No reduction require.
    ENDIF.
    IF is_zc_miro-in_thresholdamountdiff > 0.
*      rv_in_tan_tax_amount = ( -1 * ( is_zc_miro-in_thresholdamountdiff * lc_point_1_percent / 100 ) ).
      rv_in_tan_tax_amount = ( ( is_zc_miro-purchaseorderamount - is_zc_miro-in_thresholdamountdiff ) * lc_point_1_percent / 100 ).
    ELSE.
      rv_in_tan_tax_amount = ( ( is_zc_miro-purchaseorderamount ) * lc_point_1_percent / 100 ).
    ENDIF.
  ENDMETHOD.


  METHOD park_invoice.
    build_communication_with_api( ).
    buid_businessdata( 'A' ).
  ENDMETHOD.


  METHOD park_miro_api.
    DATA: lt_property          TYPE STANDARD TABLE OF string,
          lt_deep_property     TYPE STANDARD TABLE OF string,
          lt_withhold_property TYPE STANDARD TABLE OF string,
          ls_business_data     TYPE zapi_supplierinvoice_process=>tys_a_supplier_invoice_type.

    lt_property = prepare_header_properties( ).
    lt_deep_property = prepare_items_properties( ).
    lt_withhold_property = prepare_withhold_properties( ).
    TRY.
        DATA(lo_request) = mo_client_proxy->create_resource_for_entity_set( 'A_SUPPLIER_INVOICE' )->create_request_for_create( ).
        DATA(lo_data_desc_node) = lo_request->create_data_descripton_node( ).
        lo_data_desc_node->set_properties( lt_property ).

        lo_data_desc_node->add_child( 'TO_SUPLR_INVC_ITEM_PUR_ORD' )->set_properties( lt_deep_property ). "
        lo_data_desc_node->add_child( 'TO_SUPPLIER_INVOICE_WHLDG' )->set_properties( lt_withhold_property ). "

        lo_request->set_deep_business_data(
        is_business_data    = is_deep_data_new
        io_data_description = lo_data_desc_node ).

        " Execute the request
        DATA(lo_response) = lo_request->execute( ).

        " Get the after image
        lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

      CATCH: /iwbep/cx_cp_remote INTO DATA(lx_remote).
        DATA(lv_error) = lx_remote->http_error_body.
        DATA(lv_error1) = substring_before( val = lv_error sub = '"},"innererror"' ).
        DATA(lv_error2) = substring_after( val = lv_error1 sub = '"value":"' ).
      CATCH zcx_p2p_miro INTO DATA(lx_err).
        lv_error2 = ''.
*        RAISE EXCEPTION NEW zcx_p2p_miro( previous = lx_root ).
      CATCH cx_root INTO DATA(lx_root).
        lv_error2 = lx_root->get_text( ).
    ENDTRY.

    IF ls_business_data IS NOT INITIAL.
      DATA(lv_success_msg) = |Supplier invoice { ls_business_data-supplier_invoice } created for { iv_ref_doc_type } { iv_ref_id } |.
    ELSE.
      DATA(lv_fail_msg) = |Record failed for { iv_ref_doc_type } { iv_ref_id } { lv_error2 } |.
    ENDIF.

    LOOP AT it_zc_miro ASSIGNING FIELD-SYMBOL(<ls_zc_miro>).
      DATA(ls_zc_miro) = <ls_zc_miro>.
      IF ls_business_data IS NOT INITIAL.
        ls_zc_miro-supplierinvoice = ls_business_data-supplier_invoice.
        ls_zc_miro-fiscalyear = ls_business_data-fiscal_year.
      ENDIF.
      mt_output_msg = VALUE #( BASE mt_output_msg ( keys       = VALUE #( ( %key = VALUE #( purchaseorder                 = <ls_zc_miro>-purchaseorder
                                                                                            purchaseorderitem             = <ls_zc_miro>-purchaseorderitem
                                                                                            accountassignmentnumber       = <ls_zc_miro>-accountassignmentnumber
                                                                                            purchasinghistorydocument     = <ls_zc_miro>-purchasinghistorydocument
                                                                                            purchasinghistorydocumentitem = <ls_zc_miro>-purchasinghistorydocumentitem
                                                                                            purchasinghistorydocumenttype = <ls_zc_miro>-purchasinghistorydocumenttype
                                                                                            purchasinghistorydocumentyear = <ls_zc_miro>-purchasinghistorydocumentyear
                                                                                            supplierinvoice               = <ls_zc_miro>-supplierinvoice
                                                                                            fiscalyear                    = <ls_zc_miro>-fiscalyear
                                                                                            WithholdingTaxCode            = <ls_zc_miro>-WithholdingTaxCode
                                                                                            WithholdingTaxType            = <ls_zc_miro>-WithholdingTaxType  )
                                                                           %tky  = VALUE #( purchaseorder                 = <ls_zc_miro>-purchaseorder
                                                                                            purchaseorderitem             = <ls_zc_miro>-purchaseorderitem
                                                                                            accountassignmentnumber       = <ls_zc_miro>-accountassignmentnumber
                                                                                            purchasinghistorydocument     = <ls_zc_miro>-purchasinghistorydocument
                                                                                            purchasinghistorydocumentitem = <ls_zc_miro>-purchasinghistorydocumentitem
                                                                                            purchasinghistorydocumenttype = <ls_zc_miro>-purchasinghistorydocumenttype
                                                                                            purchasinghistorydocumentyear = <ls_zc_miro>-purchasinghistorydocumentyear
                                                                                            supplierinvoice               = <ls_zc_miro>-supplierinvoice
                                                                                            fiscalyear                    = <ls_zc_miro>-fiscalyear
                                                                                            WithholdingTaxCode            = <ls_zc_miro>-WithholdingTaxCode
                                                                                            WithholdingTaxType            = <ls_zc_miro>-WithholdingTaxType ) ) )
                                              zc_miro          = CORRESPONDING #( ls_zc_miro )
                                              supplier_invoice = ls_business_data-supplier_invoice
                                              year             = ls_business_data-fiscal_year
                                              msgtyp           = COND #( WHEN ls_business_data IS NOT INITIAL THEN 'S' ELSE 'E' )
                                              msg              = COND #( WHEN ls_business_data IS NOT INITIAL THEN lv_success_msg ELSE lv_fail_msg ) ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD post_invoice.
    build_communication_with_api( ).
    buid_posting_businessdata( ).
  ENDMETHOD.


  METHOD prepare_header_data.
    rs_header_business_data = VALUE #( company_code               = is_zc_miro-companycode                       "Mandatory
                                       document_date              = COND #( WHEN mv_user_documnt_dt IS NOT INITIAL
                                                                            THEN mv_user_documnt_dt
                                                                            WHEN is_zc_miro-DocumentDate IS NOT INITIAL
                                                                            THEN is_zc_miro-DocumentDate
                                                                            ELSE cl_abap_context_info=>get_system_date( ) )       "Mandatory
                                       posting_date               = COND #( WHEN mv_user_post_dt IS NOT INITIAL
                                                                            THEN mv_user_post_dt
                                                                            WHEN is_highest_posting_date IS NOT INITIAL
                                                                            THEN is_highest_posting_date
                                                                            ELSE is_zc_miro-postingdate )       "Mandatory
                                       supplier_invoice_idby_invc = COND #( WHEN mv_new_reference_no IS NOT INITIAL
                                                                            THEN mv_new_reference_no
                                                                            ELSE is_zc_miro-documentreferenceid )              "Mandatory
                                       invoicing_party            = is_zc_miro-supplier                          "Mandatory
                                       document_currency          = is_zc_miro-currency                          "Mandatory
                                       invoice_gross_amount       = iv_inv_gross_amount                            "Mandatory
                                       due_calculation_base_date  = COND #( WHEN mv_user_post_dt IS NOT INITIAL
                                                                            THEN mv_user_post_dt
                                                                            WHEN is_highest_posting_date IS NOT INITIAL
                                                                            THEN is_highest_posting_date
                                                                            ELSE is_zc_miro-postingdate ) "documentdate
                                       supplier_invoice_status    = iv_supplierinvoicestatus  "'A' for park, 'B' for posting( BAPI Invoice ) check domain IVTYP
                                       tax_is_calculated_automati = abap_true
                                       business_place             = is_zc_miro-companycode "plant
                                       business_section_code      = is_zc_miro-companycode "plant
*                                       business_area              = is_zc_miro-companycode "plant
                                       tax_determination_date     = cl_abap_context_info=>get_system_date( ) ).
  ENDMETHOD.


  METHOD prepare_header_properties.
    rs_header_prpty = VALUE #( ( CONV string( 'BUSINESS_PLACE' ) )
                            ( CONV string( 'COMPANY_CODE' ) )
                            ( CONV string( 'DOCUMENT_DATE' ) )
                            ( CONV string( 'POSTING_DATE' ) )
                            ( CONV string( 'BUSINESS_SECTION_CODE' ) )
                            ( CONV string( 'SUPPLIER_INVOICE_IDBY_INVC' ) )
                            ( CONV string( 'INVOICING_PARTY' ) )
                            ( CONV string( 'DOCUMENT_CURRENCY' ) )
                            ( CONV string( 'INVOICE_GROSS_AMOUNT' ) )
                            ( CONV string( 'DUE_CALCULATION_BASE_DATE' ) )
                            ( CONV string( 'SUPPLIER_INVOICE_STATUS' ) )
                            ( CONV string( 'DUE_CALCULATION_BASE_DATE' ) )
                            ( CONV string( 'TAX_DETERMINATION_DATE' ) )
                            ( CONV string( 'TAX_IS_CALCULATED_AUTOMATI' ) ) ).
  ENDMETHOD.


  METHOD prepare_items_data.
    rs_soi_deep_create = VALUE #( supplier_invoice_item      = iv_item_no                                       "Mandatory
                                  purchase_order             = is_zc_miro-purchaseorder                     "Mandatory
                                  purchase_order_item        = is_zc_miro-purchaseorderitem                 "Mandatory
                                  document_currency          = is_zc_miro-currency                          "Mandatory
                                  tax_code                   = is_zc_miro-taxcode                           "Mandatory
                                  reference_document         = is_zc_miro-materialdocument           "ls_matdoc-purchasinghistorydocument
                                  reference_document_fiscal  = is_zc_miro-materialdocumentyear       "ls_matdoc-purchasinghistorydocumentyear
                                  reference_document_item    = is_zc_miro-materialdocumentitem       "ls_matdoc-purchasinghistorydocumentitem
                                  supplier_invoice_item_amou = is_zc_miro-purchaseorderamount
                                  purchase_order_quantity_un = is_zc_miro-unitofmeasure_e             "purchaseorderquantityunit
                                  quantity_in_purchase_order = is_zc_miro-quantity
                                  service_entry_sheet        = is_zc_miro-serviceentrysheet
                                  service_entry_sheet_item   = is_zc_miro-serviceentrysheetitem ).
  ENDMETHOD.


  METHOD prepare_items_properties.
    rs_item_prpty = VALUE #( ( CONV string( 'SUPPLIER_INVOICE_ITEM' ) )
                                   ( CONV string( 'PURCHASE_ORDER' ) )
                                   ( CONV string( 'PURCHASE_ORDER_ITEM' ) )
                                   ( CONV string( 'REFERENCE_DOCUMENT' ) )
                                   ( CONV string( 'REFERENCE_DOCUMENT_FISCAL' ) )
                                   ( CONV string( 'REFERENCE_DOCUMENT_ITEM' ) )
                                   ( CONV string( 'DOCUMENT_CURRENCY' ) )
                                   ( CONV string( 'TAX_CODE' ) )
                                   ( CONV string( 'SUPPLIER_INVOICE_ITEM_AMOU' ) )
                                   ( CONV string( 'PURCHASE_ORDER_QUANTITY_UN' ) )
                                   ( CONV string( 'QUANTITY_IN_PURCHASE_ORDER' ) )
                                   ( CONV string( 'SERVICE_ENTRY_SHEET' ) )
                                   ( CONV string( 'SERVICE_ENTRY_SHEET_ITEM' ) ) ).
  ENDMETHOD.


  METHOD prepare_withhold_properties.
    rs_item_prpty = VALUE #( ( CONV string( 'WITHHOLDING_TAX_TYPE' ) )
                                   ( CONV string( 'DOCUMENT_CURRENCY' ) )
                                   ( CONV string( 'WITHHOLDING_TAX_CODE' ) )
                                   ( CONV string( 'WITHHOLDING_TAX_BASE_AMOUN' ) )
                                   ( CONV string( 'MANUALLY_ENTERED_WHLDG_TAX' ) ) ).
  ENDMETHOD.


  METHOD prepare_withhold_tax_data.
*    CHECK is_zc_miro-taxcode = '4Q'.
    rs_whld_deep_create = VALUE #( withholding_tax_type = is_zc_miro-withholdingtaxtype
                                   document_currency = is_zc_miro-currency
                                   withholding_tax_code = is_zc_miro-withholdingtaxcode
                                   withholding_tax_base_amoun = 0
                                   manually_entered_whldg_tax = 0 ).
*                                   manually_entered_whldg_tax = iv_withhold_amt ).
  ENDMETHOD.
ENDCLASS.
