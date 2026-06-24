CLASS lhc_zc_miro DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

*    TYPES : BEGIN OF ty_supplier_tan_tax_amt_det,
*              supplier        TYPE zc_miro-supplier,
*              diff_amt        TYPE zc_miro-in_thresholdamountdiff,
*              diff_percnt_amt TYPE zc_miro-in_thresholdamountdiff,
*            END OF ty_supplier_tan_tax_amt_det,
*            tyt_supplier_tan_tax_amt_det TYPE STANDARD TABLE OF ty_supplier_tan_tax_amt_det.

    CONSTANTS: BEGIN OF mc_miro_inv_status,
                 deleted TYPE zc_miro-supplierinvoicestatusnum VALUE '2',
               END OF mc_miro_inv_status.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_miro RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_miro RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_miro.

    METHODS parkinvoice FOR MODIFY
      IMPORTING keys FOR ACTION zc_miro~parkinvoice RESULT result.

    METHODS postinvoice FOR MODIFY
      IMPORTING keys FOR ACTION zc_miro~postinvoice RESULT result.

    METHODS CalcAndShowTotal FOR MODIFY
      IMPORTING keys FOR ACTION zc_miro~CalcAndShowTotal RESULT result.

    METHODS precheck_parkinvoice FOR PRECHECK
      IMPORTING key FOR ACTION zc_miro~parkinvoice.

    METHODS precheck_postinvoice FOR PRECHECK
      IMPORTING key FOR ACTION zc_miro~postinvoice.

    METHODS getdefaultsforplainact FOR READ
      IMPORTING keys FOR FUNCTION zc_miro~getdefaultsforparkinvoice RESULT result.

ENDCLASS.

CLASS lhc_zc_miro IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
*  LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_miro>) GROUP BY <ls_miro>-%tky.
    SELECT * FROM zc_miro
    FOR ALL ENTRIES IN @keys
    WHERE purchaseorder = @keys-purchaseorder
      AND purchaseorderitem = @keys-purchaseorderitem
      AND accountassignmentnumber = @keys-accountassignmentnumber
      AND purchasinghistorydocumenttype = @keys-purchasinghistorydocumenttype
      AND purchasinghistorydocumentyear = @keys-purchasinghistorydocumentyear
      AND purchasinghistorydocument = @keys-purchasinghistorydocument
      AND purchasinghistorydocumentitem = @keys-purchasinghistorydocumentitem
      AND supplierinvoice = @keys-supplierinvoice
      AND fiscalyear = @keys-fiscalyear
      AND WithholdingTaxCode = @keys-WithholdingTaxCode
      AND WithholdingTaxType = @keys-WithholdingTaxType
      INTO TABLE @DATA(lt_zc_miro).
    IF sy-subrc = 0.
      result = CORRESPONDING #( lt_zc_miro ).
    ENDIF.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD parkinvoice.
    DATA: lt_miro_tmp                 TYPE TABLE FOR READ RESULT zc_miro.

    DATA(lv_po) = keys[ 1 ]-purchaseorder.
    READ ENTITIES OF zc_miro IN LOCAL MODE
    ENTITY zc_miro
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_miro)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).
    IF lt_miro IS INITIAL.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
        APPEND VALUE #( %tky = <ls_key>-%tky
                                        %msg = new_message(
                                        id       = 'ZMIRO_MSG'
                                        number   = '003'
                                        severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.
      ENDLOOP.
    ENDIF.
    DATA(ls_parameters) = keys[ 1 ]-%param.
    TRY.
        lt_miro_tmp = lt_miro.
        DATA(lo_miro_utility) = NEW zcl_miro_utility( it_zc_miro = CORRESPONDING #( lt_miro_tmp )
                                                      iv_user_post_dt = ls_parameters-posting_date_by_user
                                                      iv_user_documnt_dt = ls_parameters-document_date_by_user
                                                      iv_new_reference_no = ls_parameters-new_reference_no
                                                      iv_user_inv_gross_amt = ls_parameters-usr_choice_inv_gross_amt
                                                      iv_grp_by       = COND #( WHEN ls_parameters-grp_by_grn = abap_true THEN zcl_miro_utility=>cs_collective_by-gn
                                                                                WHEN ls_parameters-grp_by_po  = abap_true THEN zcl_miro_utility=>cs_collective_by-po
                                                                                ELSE '' ) ).
        DATA(lt_msg) = lo_miro_utility->park_invoice( ).
        LOOP AT lo_miro_utility->mt_output_msg ASSIGNING FIELD-SYMBOL(<fs_log>).
          DATA(lv_length) = strlen( <fs_log>-msg ).
          IF lv_length <= 50.
            DATA(lv_msg_v1) = substring( val = <fs_log>-msg off = 0 len = lv_length ).
          ELSE.
            lv_msg_v1 = substring( val = <fs_log>-msg off = 0 len = 50 ).
          ENDIF.
          IF lv_length > 50.
            DATA(lv_msg_v2) = substring( val = <fs_log>-msg off = 49 len = lv_length - 51 ).
          ENDIF.
          IF lv_length > 100.
            DATA(lv_msg_v3) = substring( val = <fs_log>-msg off = 98 len = lv_length - 101 ).
          ENDIF.
          IF lv_length > 150.
            DATA(lv_msg_v4) = substring( val = <fs_log>-msg off = 147 len = lv_length - 151 ).
          ENDIF.
          APPEND VALUE #( %key = <fs_log>-keys[ 1 ]-%key
                                  %msg = new_message(
                                  id       = 'ZMIRO_MSG'
                                  number   = '000'
                                  v1       = lv_msg_v1
                                  v2       = lv_msg_v2
                                  v3       = lv_msg_v3
                                  v4       = lv_msg_v4
                                  severity = COND #( WHEN <fs_log>-msgtyp = 'E' THEN  if_abap_behv_message=>severity-error
                                                     ELSE if_abap_behv_message=>severity-success ) )
                                ) TO reported-zc_miro.
          result = VALUE #( BASE result ( %key = <fs_log>-keys[ 1 ]-%key
                                          %param = CORRESPONDING #( <fs_log>-zc_miro ) ) ).
        ENDLOOP.
      CATCH zcx_p2p_miro INTO DATA(lx_apis).
        LOOP AT lt_miro_tmp ASSIGNING FIELD-SYMBOL(<ls_miro_tmp>).
          APPEND VALUE #( %key = <ls_miro_tmp>-%key
                                        %msg = new_message(
                                        id       = lx_apis->if_t100_message~t100key-msgid
                                        number   = lx_apis->if_t100_message~t100key-msgno
                                        v1       = lx_apis->if_t100_message~t100key-attr1
                                        v2       = lx_apis->if_t100_message~t100key-attr2
                                        v3       = lx_apis->if_t100_message~t100key-attr3
                                        v4       = lx_apis->if_t100_message~t100key-attr4
                                        severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.
        ENDLOOP.
    ENDTRY.
  ENDMETHOD.

  METHOD postinvoice.
    DATA: lt_miro_tmp TYPE TABLE FOR READ RESULT zc_miro.
    READ ENTITIES OF zc_miro IN LOCAL MODE
      ENTITY zc_miro
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_miro).

    TRY.
        LOOP AT lt_miro ASSIGNING FIELD-SYMBOL(<ls_miro>).
          APPEND <ls_miro> TO lt_miro_tmp.
          DATA(lo_miro_utility) = NEW zcl_miro_utility( CORRESPONDING #( lt_miro_tmp ) ).
          DATA(lt_msg) = lo_miro_utility->post_invoice( ).

          LOOP AT lo_miro_utility->mt_output_msg ASSIGNING FIELD-SYMBOL(<fs_log>).

            DATA(lv_length) = strlen( <fs_log>-msg ).
            IF lv_length <= 50.
              DATA(lv_msg_v1) = substring( val = <fs_log>-msg off = 0 len = lv_length ).
            ELSE.
              lv_msg_v1 = substring( val = <fs_log>-msg off = 0 len = 50 ).
            ENDIF.
            IF lv_length > 50.
              DATA(lv_msg_v2) = substring( val = <fs_log>-msg off = 49 len = lv_length - 51 ).
            ENDIF.
            IF lv_length > 100.
              DATA(lv_msg_v3) = substring( val = <fs_log>-msg off = 98 len = lv_length - 101 ).
            ENDIF.
            IF lv_length > 150.
              DATA(lv_msg_v4) = substring( val = <fs_log>-msg off = 147 len = lv_length - 151 ).
            ENDIF.
            APPEND VALUE #( %key = <fs_log>-keys[ 1 ]-%key
                                    %msg = new_message(
                                    id       = 'ZMIRO_MSG'
                                    number   = '000'
                                    v1       = lv_msg_v1
                                    v2       = lv_msg_v2
                                    v3       = lv_msg_v3
                                    v4       = lv_msg_v4
                                    severity = COND #( WHEN <fs_log>-msgtyp = 'E' THEN  if_abap_behv_message=>severity-error
                                                       ELSE if_abap_behv_message=>severity-success ) )
*                      %element-CustomerID = if_abap_behv=>mk-on
                                  ) TO reported-zc_miro.
          ENDLOOP.
          CLEAR lt_miro_tmp[].
        ENDLOOP.

      CATCH zcx_p2p_miro INTO DATA(lx_apis).
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD precheck_parkinvoice.
    READ ENTITIES OF zc_miro IN LOCAL MODE
    ENTITY zc_miro
    ALL FIELDS WITH CORRESPONDING #( key )
    RESULT DATA(lt_miro).

*  Validation: Check if both group by is not selected by user.
    ASSIGN key[ 1 ] TO FIELD-SYMBOL(<ls_key>).
    IF sy-subrc = 0.
      IF <ls_key>-%param-grp_by_grn = abap_true AND <ls_key>-%param-grp_by_po = abap_true.
        APPEND VALUE #( %key = <ls_key>-%key
                        %msg = new_message( id       = 'ZMIRO_MSG'
                                            number   = '000'
                                            v1       = 'Please select only one collective drop down'
                                            severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_key>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
        RETURN.
      ENDIF.
      ASSIGN lt_miro[ Quantity = 0 ]-quantity TO FIELD-SYMBOL(<lv_qty>).
      IF sy-subrc = 0.
        APPEND VALUE #( %key = <ls_key>-%key
                          %msg = new_message( id       = 'ZMIRO_MSG'
                                              number   = '000'
                                              v1       = 'Entry with empty quantity is not allowed for parking.'
                                              severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_key>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
        RETURN.
      ENDIF.
      IF <ls_key>-%param-grp_by_grn = abap_true AND <ls_key>-%param-usr_choice_inv_gross_amt IS NOT INITIAL.
        DATA(lt_miro_tmp) = lt_miro.
        SORT lt_miro_tmp BY materialdocumentyear materialdocument.
        DELETE ADJACENT DUPLICATES FROM lt_miro_tmp COMPARING materialdocumentyear materialdocument.
        IF lines( lt_miro_tmp ) > 1.
*  Validation: User can group only for one GRN document with input gross amount
          APPEND VALUE #( %key = <ls_key>-%key
                         %msg = new_message( id       = 'ZMIRO_MSG'
                                             number   = '000'
                                             v1       = 'Please group one GRN document with gross amount'
                                             severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
        ENDIF.
      ENDIF.

      IF <ls_key>-%param-grp_by_po = abap_true AND <ls_key>-%param-usr_choice_inv_gross_amt IS NOT INITIAL.
        lt_miro_tmp = lt_miro.
        SORT lt_miro_tmp BY purchaseorder.
        DELETE ADJACENT DUPLICATES FROM lt_miro_tmp COMPARING purchaseorder.
        IF lines( lt_miro_tmp ) > 1.
*  Validation: Please group only one PO document with gross amount
          APPEND VALUE #( %key = <ls_key>-%key
                         %msg = new_message( id       = 'ZMIRO_MSG'
                                             number   = '000'
                                             v1       = 'Please group one PO document with gross amount'
                                             severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
        ENDIF.
      ENDIF.

      IF <ls_key>-%param-grp_by_po = abap_true.
        lt_miro_tmp = lt_miro.
        DATA(lt_miro_dup) = lt_miro_tmp.
        SORT lt_miro_dup BY purchaseorder PurchaseOrderItem material.
        DELETE ADJACENT DUPLICATES FROM lt_miro_dup COMPARING purchaseorder PurchaseOrderItem material.
        SELECT purchaseorder, material, COUNT( * ) AS cnt
        FROM @lt_miro_dup AS miro_tmp
        GROUP BY purchaseorder, material
        INTO TABLE @DATA(lt_dup_miro).
        LOOP AT lt_dup_miro TRANSPORTING NO FIELDS WHERE cnt > 1.
          APPEND VALUE #( %key = <ls_key>-%key
                          %msg = new_message( id       = 'ZMIRO_MSG'
                                              number   = '000'
                                              v1       = 'Multi items of a PO having same material not allowed'
                                              severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

          APPEND VALUE #( %key = <ls_key>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
          RETURN.
        ENDLOOP.
        SORT lt_miro_tmp BY purchaseorder PurchaseOrderItem.
*        IF lt_miro_tmp IS NOT INITIAL.
*          ASSIGN lt_miro_tmp[ 1 ] TO FIELD-SYMBOL(<ls_miro_tmp>).
*          IF sy-subrc = 0.
*            LOOP AT lt_miro_tmp TRANSPORTING NO FIELDS WHERE PurchaseOrderItem <> <ls_miro_tmp>-PurchaseOrderItem.
*              APPEND VALUE #( %key = <ls_key>-%key
*                               %msg = new_message( id       = 'ZMIRO_MSG'
*                                                   number   = '000'
*                                                   v1       = 'A PO with multiple different items is not allowed'
*                                                   severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.
*
*              APPEND VALUE #( %key = <ls_key>-%key
*                              %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
*              RETURN.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
        IF lt_miro_tmp IS NOT INITIAL.
          ASSIGN lt_miro_tmp[ 1 ] TO FIELD-SYMBOL(<ls_miro_tmp>).
          IF sy-subrc = 0.
            LOOP AT lt_miro_tmp TRANSPORTING NO FIELDS WHERE PurchaseOrder <> <ls_miro_tmp>-PurchaseOrder.
              APPEND VALUE #( %key = <ls_key>-%key
                               %msg = new_message( id       = 'ZMIRO_MSG'
                                                   number   = '000'
                                                   v1       = |Multiple different PO's are not allowed in grouping|
                                                   severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

              APPEND VALUE #( %key = <ls_key>-%key
                              %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) TO failed-zc_miro.
              RETURN.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

    IF lt_miro IS NOT INITIAL.
*      SELECT materialdocumentyear, materialdocument, materialdocumentitem, reversedmaterialdocument
*      FROM i_materialdocumentitem_2
*      FOR ALL ENTRIES IN @lt_miro
*      WHERE materialdocumentyear = @lt_miro-materialdocumentyear
*        AND materialdocument     = @lt_miro-materialdocument
*        AND materialdocumentitem = @lt_miro-materialdocumentitem
*      INTO TABLE @DATA(lt_matdoc).
*      IF sy-subrc = 0.
*        SELECT COUNT( * ) AS reverse_cnt FROM @lt_matdoc AS _matdoc
*        WHERE reversedmaterialdocument IS NOT INITIAL
*        INTO @DATA(ls_reverse_cnt).
*
*      ENDIF.

      SELECT * FROM zi_miro_supplier_invoice  "#EC CI_ALL_FIELDS_NEEDED
      FOR ALL ENTRIES IN @lt_miro
       WHERE purchaseorder = @lt_miro-purchaseorder
         AND purchaseorderitem           = @lt_miro-purchaseorderitem
         AND referencedocument           = @lt_miro-materialdocument
         AND referencedocumentfiscalyear = @lt_miro-materialdocumentyear
         AND referencedocumentitem       = @lt_miro-materialdocumentitem
         AND isinvoice                   = 'X'
     INTO TABLE @DATA(lt_supplier_inv).
      IF sy-subrc = 0.
        SELECT COUNT( * ) AS reverse_cnt FROM @lt_supplier_inv AS _matdoc
        WHERE reversedocument IS NOT INITIAL
        INTO @DATA(ls_reverse_cnt).
      ENDIF.
    ENDIF.
    LOOP AT lt_miro ASSIGNING FIELD-SYMBOL(<ls_miro>).
*      Validation 2: Invoice already exist.
      IF <ls_miro>-supplierinvoice IS NOT INITIAL.
        ASSIGN lt_supplier_inv[ purchaseorder = <ls_miro>-purchaseorder purchaseorderitem = <ls_miro>-purchaseorderitem ] TO FIELD-SYMBOL(<ls_supplier_inv>).
        IF sy-subrc = 0 AND <ls_supplier_inv>-reversedocument IS INITIAL.
          APPEND VALUE #( %key = <ls_miro>-%key
                          %msg = new_message(
                                    id       = 'ZMIRO_MSG'
                                    number   = '000'
                                    v1       = 'Invoice already exist for the record'
                                    severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

          APPEND VALUE #( %key = <ls_miro>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                          ) TO failed-zc_miro.
          RETURN.
        ENDIF.
      ENDIF.
      SELECT count( * ) as withholdingtaxcount FROM i_supplierwithholdingtax
      WHERE supplier = @<ls_miro>-supplier
        AND companycode = @<ls_miro>-companycode
        AND withholdingtaxcode in ( 'B1' , 'B2' ) "<> '4Q'
      INTO @DATA(lv_wthtax_cnt).
      if lv_wthtax_cnt > 1.
      APPEND VALUE #( %key = <ls_miro>-%key
                           %msg = new_message(
                                     id       = 'ZMIRO_MSG'
                                     number   = '010'
                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_miro>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                        ) TO failed-zc_miro.
        RETURN.
      endif.
*      Validation 2: TAN exemption not maintained for 4Q tax code.
      SELECT SINGLE @abap_true AS value_exist FROM i_supplierwithholdingtax
      WHERE supplier = @<ls_miro>-supplier
        AND companycode = @<ls_miro>-companycode
        AND withholdingtaxcode = '4Q'
      INTO @DATA(ls_4q_exist).

      SELECT SINGLE @abap_true AS value_exist FROM i_in_tanexemptiondetail
      WHERE customersupplieraccount = @<ls_miro>-supplier
        AND companycode = @<ls_miro>-companycode
        AND withholdingtaxcode = '4Q'
      INTO @DATA(ls_tan_exempt_exist).

      IF ls_4q_exist = abap_true AND ls_tan_exempt_exist = abap_false.
        APPEND VALUE #( %key = <ls_miro>-%key
                           %msg = new_message(
                                     id       = 'ZMIRO_MSG'
                                     number   = '005'
                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_miro>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                        ) TO failed-zc_miro.
        RETURN.
      ENDIF.

      IF <ls_miro>-WithholdingTaxCode IS INITIAL.
        APPEND VALUE #( %key = <ls_miro>-%key
                             %msg = new_message(
                                       id       = 'ZMIRO_MSG'
                                       number   = '009'
                                       severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_miro>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                        ) TO failed-zc_miro.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF lt_miro IS NOT INITIAL.
      SELECT COUNT( * ) AS no_of_records
            FROM zc_miro
            FOR ALL ENTRIES IN @lt_miro
            WHERE materialdocumentyear = @lt_miro-materialdocumentyear
              AND materialdocument     = @lt_miro-materialdocument
              AND ( supplierinvoice IS NULL OR supplierinvoice = '' OR supplierinvoice = ' ' OR SupplierInvoiceStatus = 'Cancelled' )
            INTO @DATA(ls_miro_cnt).


*     Validation 2: check if all GRN records are selected.
*      IF ( ls_miro_cnt + ls_reverse_cnt ) <> lines( lt_miro ).
      IF ( ls_miro_cnt ) <> lines( lt_miro ).
        APPEND VALUE #( %key = <ls_miro>-%key
                        %msg = new_message(
                                  id       = 'ZMIRO_MSG'
                                  number   = '000'
                                  v1       = 'Please select all GRN items'
                                  severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

        APPEND VALUE #( %key = <ls_miro>-%key
                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                        ) TO failed-zc_miro.
        RETURN.
      ENDIF.

      IF <ls_key>-%param-grp_by_grn = abap_false.
        SELECT zc_miro~materialdocument, zc_miro~materialdocumentyear, COUNT( * ) AS no_of_records
              FROM zc_miro
              INNER JOIN @lt_miro AS lt_miro
              ON   zc_miro~materialdocumentyear = lt_miro~materialdocumentyear
                AND zc_miro~materialdocument    = lt_miro~materialdocument
                AND ( zc_miro~supplierinvoice IS NULL OR zc_miro~SupplierInvoiceStatus = 'Cancelled' )
              GROUP BY zc_miro~materialdocument, zc_miro~materialdocumentyear
              INTO TABLE @DATA(lt_miro_per_grn).


        LOOP AT lt_miro_per_grn ASSIGNING FIELD-SYMBOL(<ls_per_grn>) WHERE no_of_records > 1.
          APPEND VALUE #( %key = <ls_miro>-%key
                           %msg = new_message(
                                     id       = 'ZMIRO_MSG'
                                     number   = '007'           "Please select yes for Single Miro for a GRN with multiple items
                                     severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.

          APPEND VALUE #( %key = <ls_miro>-%key
                          %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
                          ) TO failed-zc_miro.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_postinvoice.

    READ ENTITIES OF zc_miro IN LOCAL MODE
        ENTITY zc_miro
        ALL FIELDS WITH CORRESPONDING #( key )
        RESULT DATA(lt_miro).

    LOOP AT lt_miro ASSIGNING FIELD-SYMBOL(<ls_miro>).
*    Validation 1: check status
*      IF <ls_miro>-supplierinvoicestatusnum = mc_miro_inv_status-deleted.
*        APPEND VALUE #( %key = <ls_miro>-%key
*                        %msg = new_message(
*                                  id       = 'ZMIRO_MSG'
*                                  number   = '004'
*                                  severity = if_abap_behv_message=>severity-error ) ) TO reported-zc_miro.
*
*        APPEND VALUE #( %key = <ls_miro>-%key
*                        %fail = VALUE #( cause = if_abap_behv=>cause-conflict )
*                        ) TO failed-zc_miro.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD getdefaultsforplainact.
    READ ENTITIES OF zc_miro IN LOCAL MODE
        ENTITY zc_miro
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_miro).

*    SELECT MAX( postingdate ) AS posting_date
*    FROM @lt_miro AS miro
*    INTO @DATA(lv_max_posting_date).

    LOOP AT lt_miro ASSIGNING FIELD-SYMBOL(<ls_miro>).
      APPEND VALUE #( %tky    = <ls_miro>-%tky
                      %param  = VALUE #( "posting_date_by_user = cl_abap_context_info=>get_system_date( )
*                                                                       ELSE cl_abap_context_info=>get_system_date( ) )
                                         usr_choice_inv_gross_amt = 0  ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD calcandshowtotal.
    DATA: lv_total    TYPE zcl_miro_utility=>tyv_amt,
          lv_currency TYPE zc_miro-Currency.

    READ ENTITIES OF zc_miro IN LOCAL MODE
        ENTITY zc_miro
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_miro).

    LOOP AT lt_miro ASSIGNING FIELD-SYMBOL(<ls_miro>).
      lv_total += <ls_miro>-purchaseorderamount + <ls_miro>-cgst_value + <ls_miro>-sgst_value + <ls_miro>-igst_value.
      lv_currency = <ls_miro>-Currency.
    ENDLOOP.

    APPEND VALUE #( %key = keys[ 1 ]-%key
                           %msg = new_message(
                                     id       = 'ZMIRO_MSG'
                                     number   = '008'           "Total amount for selected entries is &1 &2
                                     severity = if_abap_behv_message=>severity-information
                                     v1 = lv_total
                                     v2 = lv_currency ) ) TO reported-zc_miro.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_miro DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_miro IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
