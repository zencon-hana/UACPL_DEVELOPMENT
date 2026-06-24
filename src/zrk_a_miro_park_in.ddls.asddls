@EndUserText.label: 'Abstract entity for MIRO park'
define root abstract entity zrk_a_miro_park_in
  //  with parameters parameter_name : parameter_type
{
  @EndUserText.label       : 'Posting date'
  //  @UI.defaultValue     : '20240505'
  posting_date_by_user     : budat;
  document_date_by_user    : bldat;
  @EndUserText.label       : 'New invoice number'
  new_reference_no         : abap.char( 30 );
  //  @Semantics.amount.currencyCode : 'I_MaterialDocumentItem_2.CompanyCodeCurrency'
  //  usr_choice_inv_gross_amt : dmbtr_cs;
  @EndUserText.label       : 'Invoice Gross amount'
  //  @UI.defaultValue : '0.00'
  usr_choice_inv_gross_amt : abap.dec( 10, 2 );
  //  @EndUserText.label   : 'Collective MIRO'
  //  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: ZD_P2P_MIRO_COLLECTIVE_BY' )
  //  grp_by : zd_p2p_miro_collective_by;
  @EndUserText.label       : 'Single MIRO for a PO & item combination'
  grp_by_po                : abap_boolean;
  @EndUserText.label       : 'Single Miro for a GRN with multi items'
  grp_by_grn               : abap_boolean;
}
