@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for MIRO'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_MIRO_BASE_CALC
  as select from ZI_MIRO_BASE
  association [0..*] to ZI_MIRO_BASE                   as _BaseCalc  on  _BaseCalc.Supplier                    = $projection.Supplier
                                                                     and _BaseCalc.DocumentReferenceID         = $projection.DocumentReferenceID
                                                                     and _BaseCalc.DocumentDate                = $projection.DocumentDate
                                                                     and _BaseCalc.PurchaseOrder               = $projection.PurchaseOrder
                                                                     and _BaseCalc.PurchaseOrderItem           = $projection.PurchaseOrderItem
                                                                     and _BaseCalc.ReferenceDocument           = $projection.ReferenceDocument
                                                                     and _BaseCalc.ReferenceDocumentFiscalYear = $projection.ReferenceDocumentFiscalYear
                                                                     and _BaseCalc.ReferenceDocumentItem       = $projection.ReferenceDocumentItem

  association [0..1] to I_PurOrdAccountAssignmentAPI01 as _POAccount on  _POAccount.PurchaseOrder           = $projection.PurchaseOrder
                                                                     and _POAccount.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                     and _POAccount.AccountAssignmentNumber = '01'

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
      QuantityInDeliveryQtyUnit,     //lsmng
      DeliveryQuantityUnit,          //lsmeh

      @Semantics.quantity.unitOfMeasure:'PurchaseOrderQuantityUnit'
      Quantity,
      //      sum( case when _BaseCalc.DebitCreditCode = 'H'
      //      then ( Quantity - _BaseCalc.Quantity )
      //      else ( Quantity + _BaseCalc.Quantity ) end )                                           as Quantity, //menge

      @Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      sum( case when _BaseCalc.DebitCreditCode = 'H'
      then ( QtyInPurchaseOrderPriceUnit - _BaseCalc.QtyInPurchaseOrderPriceUnit )
      else ( QtyInPurchaseOrderPriceUnit + _BaseCalc.QtyInPurchaseOrderPriceUnit ) end )     as QtyInPurchaseOrderPriceUnit, //bpmng

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case when _BaseCalc.DebitCreditCode = 'H'
      then cast(( PurOrdAmountInCompanyCodeCrcy - _BaseCalc.PurOrdAmountInCompanyCodeCrcy ) as abap.dec(23,2))
      else cast(( PurOrdAmountInCompanyCodeCrcy + _BaseCalc.PurOrdAmountInCompanyCodeCrcy ) as abap.dec(23,2))
       end ) as PurOrdAmountInCompanyCodeCrcy, //dmbtr

      @Semantics.amount.currencyCode: 'Currency'
      cast(PurchaseOrderAmount as abap.dec(23,2)) as PurchaseOrderAmount,           //wrbtr
      Currency,                      //waers
      DebitCreditCode,               //shkzg
      PurchaseOrderQuantityUnit,
      OrderPriceUnit,
      CompanyCodeCurrency,
      PurchaseOrderItemCategory,     //pstyp
      @Semantics.text: true
      PurchaseOrderItemText,         //txz01
      @Semantics.amount.currencyCode: 'ItemDocumentCurrency'
      @DefaultAggregation: #NONE
      cast(NetPriceAmount as abap.dec(23,2)) as NetPriceAmount, //netpr
      @Semantics.quantity.unitOfMeasure: 'ItemOrderPriceUnit'
      NetPriceQuantity,              //peinh
      AccountAssignmentCategory,     //knttp
      ItemPurchaseOrderCategory,     //webre
      TaxCode,                       //mwskz
      StorageLocation,               //lgort
      ItemDocumentCurrency,
      ItemOrderPriceUnit,
      PurchasingDocumentCategory,    //bstyp
      PaymentTerms,                  //zterm
      CompanyCode,                   //bukrs
      Supplier, //lifnr
      _POAccount.MasterFixedAsset as AssetNo,
      _POAccount.GLAccount

}
where
  (
       GoodsMovementType = '101'
    or GoodsMovementType = '105'
  )

group by
  PurchaseOrder,                 //ebeln
  PurchaseOrderItem,             //ebelp
  AccountAssignmentNumber,       //zekkn
  PurchasingHistoryDocumentType, //vgabe
  PurchasingHistoryDocumentYear, //gjahr
  PurchasingHistoryDocument,     //belnr
  PurchasingHistoryDocumentItem, //buzei
  DocumentReferenceID,           //xblnr
  DocumentDate,                  //bldat
  ReferenceDocument,             //lfbnr
  ReferenceDocumentFiscalYear,   //lfgja
  ReferenceDocumentItem,         //lfpos
  PostingDate,                   //budat
  Material,                      //matnr
  Plant,                         //werks
  GoodsMovementType,             //bwart
  QuantityInDeliveryQtyUnit,     //lsmng
  DeliveryQuantityUnit,          //lsmeh
  QtyInPurchaseOrderPriceUnit,   //bpmng
  PurOrdAmountInCompanyCodeCrcy, //dmbtr
  PurchaseOrderAmount,           //wrbtr
  Currency,                      //waers
  DebitCreditCode,               //shkzg
  PurchaseOrderQuantityUnit,
  OrderPriceUnit,
  Quantity,
  CompanyCodeCurrency,
  PurchaseOrderItemCategory,     //pstyp
  PurchaseOrderItemText,         //txz01
  NetPriceAmount,                //netpr
  NetPriceQuantity,              //peinh
  AccountAssignmentCategory,     //knttp
  ItemPurchaseOrderCategory,     //webre
  TaxCode,                       //mwskz
  StorageLocation,               // lgort
  ItemDocumentCurrency,
  ItemOrderPriceUnit,
  PurchasingDocumentCategory,    //bstyp
  PaymentTerms,                  //zterm
  CompanyCode,                   //bukrs
  Supplier, //lifnr
  _POAccount.MasterFixedAsset,
  _POAccount.GLAccount
