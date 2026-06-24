@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for supplier invoice'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_miro_supplier_invoice
  as select from I_SuplrInvcItemPurOrdRefAPI01
{
  key SupplierInvoice,                                     //belnr
  key FiscalYear,                                          //gjahr
  key SupplierInvoiceItem,                                 //buzei
      PurchaseOrder,                                       //ebeln
      PurchaseOrderItem,                                   //ebelp
      ReferenceDocument,                                   //lfbnr
      ReferenceDocumentFiscalYear,                         //lfgja
      ReferenceDocumentItem,                               //lfpos
      cast( cast( concat( '0',ReferenceDocumentItem ) as abap.char( 5 ) ) as abap.numc( 5 )) as ReferenceDocumentItem5,                               //lfpos
      _SupplierInvoiceAPI01.IsInvoice,                     //xrech
      _SupplierInvoiceAPI01.AssignmentReference,           //zuonr
      _SupplierInvoiceAPI01.SupplierInvoiceIDByInvcgParty, //xblnr
      _SupplierInvoiceAPI01.PostingDate,                   //budat
      _SupplierInvoiceAPI01.DocumentDate,                   //bldat
      _SupplierInvoiceAPI01.SupplierInvoiceStatus,          //rbstat isstat
      _SupplierInvoiceAPI01.ReverseDocument,
      _SupplierInvoiceAPI01.ReverseDocumentFiscalYear
}
