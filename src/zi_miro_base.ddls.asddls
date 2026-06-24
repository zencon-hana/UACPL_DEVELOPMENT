@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for MIRO'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_MIRO_BASE  
  as select from I_PurchaseOrderHistoryAPI01
{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' } }]
  key PurchaseOrder,                 //ebeln
  key PurchaseOrderItem,             //ebelp
  key AccountAssignmentNumber,       //zekkn
  key PurchasingHistoryDocumentType, //vgabe
  key PurchasingHistoryDocumentYear, //gjahr
  key PurchasingHistoryDocument,     //belnr
  key PurchasingHistoryDocumentItem, //buzei
      DocumentReferenceID,           //xblnr
      DocumentDate,                  //bldat
      ReferenceDocument,             //lfbnr
      ReferenceDocumentFiscalYear,   //lfgja
      ReferenceDocumentItem,         //lfpos
      PostingDate,                   //budat
      Material,                      //matnr
      Plant,                         //werks
      GoodsMovementType,             //bwart
      @Semantics.quantity.unitOfMeasure:'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,                    //lsmng
      DeliveryQuantityUnit,                         //lsmeh
      @Semantics.quantity.unitOfMeasure:'PurchaseOrderQuantityUnit'
      Quantity,                                     //menge
      @Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit,                  //bpmng
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      PurOrdAmountInCompanyCodeCrcy,                //dmbtr
      Currency,                                     //waers
      DebitCreditCode,                              //shkzg
      PurchaseOrderQuantityUnit,
      OrderPriceUnit,
      CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'Currency'
      PurchaseOrderAmount,                          //wrbtr

      _PurchaseOrderItem.PurchaseOrderItemCategory, //pstyp
      @Semantics.text: true
      _PurchaseOrderItem.PurchaseOrderItemText, //txz01
      @Semantics.amount.currencyCode: 'ItemDocumentCurrency'
      @DefaultAggregation: #NONE
      _PurchaseOrderItem.NetPriceAmount,            //netpr
      @Semantics.quantity.unitOfMeasure: 'ItemOrderPriceUnit'
      _PurchaseOrderItem.NetPriceQuantity,          //peinh
      _PurchaseOrderItem.AccountAssignmentCategory, //knttp
      _PurchaseOrderItem.PurchaseOrderCategory as ItemPurchaseOrderCategory, //webre
      _PurchaseOrderItem.TaxCode,                   //mwskz
      _PurchaseOrderItem.StorageLocation,           // lgort
      _PurchaseOrderItem.DocumentCurrency      as ItemDocumentCurrency,
      _PurchaseOrderItem.OrderPriceUnit        as ItemOrderPriceUnit,
      //  _PurchaseOrder.PurchasingDocumentCategory, //bstyp
      cast ( 'F' as abap.char( 1 ) )           as PurchasingDocumentCategory, //bstyp
      _PurchaseOrder.PaymentTerms, //zterm
      _PurchaseOrder.CompanyCode, //bukrs
      _PurchaseOrder.Supplier //lifnr,

}
where
  PurchasingHistoryDocumentType = '1'  and  _PurchaseOrderItem.PurchasingDocumentDeletionCode = ' ' //a~vgabe = '1'
