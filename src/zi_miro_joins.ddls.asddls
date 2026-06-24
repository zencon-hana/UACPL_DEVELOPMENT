@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for MIRO'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_MIRO_JOINS
  as select from ZI_MIRO_BASE_CALC

  association [0..1] to ZI_MIRO_MatDocItem            as _MaterialDocumentItem       on  _MaterialDocumentItem.MaterialDocumentYear = $projection.PurchasingHistoryDocumentYear
                                                                                     and _MaterialDocumentItem.MaterialDocument     = $projection.PurchasingHistoryDocument
                                                                                     and _MaterialDocumentItem.MaterialDocumentItem = $projection.PurchasingHistoryDocumentItem

  association [0..1] to I_MaterialDocumentHeader_2    as _MatDoc                     on  _MatDoc.MaterialDocumentYear = $projection.PurchasingHistoryDocumentYear
                                                                                     and _MatDoc.MaterialDocument     = $projection.PurchasingHistoryDocument

  association [0..1] to I_Supplier                    as _supplier                   on  _supplier.Supplier = $projection.Supplier

  //
  //  association [0..*] to I_SuplrInvcItemPurOrdRefAPI01 as _SupplierItem               on  _SupplierItem.PurchaseOrder               = $projection.PurchaseOrder
  //                                                                                     and _SupplierItem.PurchaseOrderItem           = $projection.PurchaseOrderItem
  //                                                                                     and _SupplierItem.ReferenceDocument           = $projection.materialdocument
  //                                                                                     and _SupplierItem.ReferenceDocumentItem       = $projection.materialdocumentitem
  //                                                                                     and _SupplierItem.ReferenceDocumentFiscalYear = $projection.materialdocumentyear

  association [1..1] to I_PurchasingDocumentCategory  as _PurchasingDocumentCategory on  $projection.PurchasingDocumentCategory = _PurchasingDocumentCategory.PurchasingDocumentCategory

  association [0..1] to I_CompanyCode                 as _CompanyCode                on  $projection.CompanyCode = _CompanyCode.CompanyCode

  association [0..1] to I_PurgDocumentItemCategory    as _PurgDocumentItemCategory   on  $projection.PurchaseOrderItemCategory = _PurgDocumentItemCategory.PurchasingDocumentItemCategory

  association [0..1] to I_PaymentTerms                as _PaymentTerms               on  $projection.PaymentTerms = _PaymentTerms.PaymentTerms

  association [0..1] to I_PurchasingDocumentCategory  as _PurgDocumentCategory       on  $projection.ItemPurchaseOrderCategory = _PurgDocumentCategory.PurchasingDocumentCategory

  association [0..1] to I_SupplierWithHoldingTax      as _SupplierWithHoldingTax     on  _SupplierWithHoldingTax.Supplier           = $projection.Supplier
                                                                                     and _SupplierWithHoldingTax.CompanyCode        = $projection.CompanyCode
                                                                                     and _SupplierWithHoldingTax.WithholdingTaxType <> '4Q'

 association [0..1] to I_SupplierWithHoldingTax      as _SupplierWithHoldingTax1     on  _SupplierWithHoldingTax1.Supplier           = $projection.Supplier
                                                                                     and _SupplierWithHoldingTax1.CompanyCode        = $projection.CompanyCode
                                                                                     and _SupplierWithHoldingTax1.WithholdingTaxType = '4Q'
                                                                                                                                                                          
  association [0..1] to ZI_MIRO_ServiceEntrySheetItem as _ServiceEntrySheetItem      on  _ServiceEntrySheetItem.PurchaseOrder        = $projection.PurchaseOrder
                                                                                     and _ServiceEntrySheetItem.PurchaseOrderItem    = $projection.PurchaseOrderItem
                                                                                     and _ServiceEntrySheetItem.MaterialDocument     = $projection.PurchasingHistoryDocument
                                                                                     and _ServiceEntrySheetItem.MaterialDocumentYear = $projection.PurchasingHistoryDocumentYear


{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' } }]
  key PurchaseOrder,                 //ebeln
  key PurchaseOrderItem,             //ebelp
  key AccountAssignmentNumber,       //zekkn
  key PurchasingHistoryDocumentType, //vgabe
  key PurchasingHistoryDocumentYear, //gjahr
  key PurchasingHistoryDocument,     //belnr
  key PurchasingHistoryDocumentItem, //buzei
      case when _ServiceEntrySheetItem.ServiceEntrySheet is null
      then DocumentReferenceID
      else _ServiceEntrySheetItem.ServiceEntrySheetName end                                                                    as DocumentReferenceID, //xblnr
      DocumentDate,                  //bldat
      ReferenceDocument,             //lfbnr
      ReferenceDocumentFiscalYear,   //lfgja
      ReferenceDocumentItem,         //lfpos
      //      PostingDate,                   //budat
      case when _MatDoc.CreationTime between '183000' and '240000'
      then
      dats_add_days(_MatDoc.CreationDate,1,'NULL')
      else
      _MatDoc.CreationDate end                                                                                                 as PostingDate,
      _MatDoc.CreationDate                                                                                                     as MatDocCreateDate,
      _MatDoc.CreationTime                                                                                                     as MatDocCreateTime,
      //      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Material', element: 'Material ' } }]
      Material,                      //matnr
      Plant,                         //werks
      GoodsMovementType,             //bwart
      @Semantics.quantity.unitOfMeasure:'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,     //lsmng
      DeliveryQuantityUnit,          //lsmeh
      @Semantics.quantity.unitOfMeasure:'PurchaseOrderQuantityUnit'
      _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit                                                                        as Quantity,
      //      Quantity,                      //menge
      @Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit, //bpmng
      //      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      case when AccountAssignmentCategory = 'A'
      //      then cast( ( QtyInPurchaseOrderPriceUnit * curr_to_decfloat_amount( NetPriceAmount ) ) as abap.curr( 14, 2 ) )
      then cast( ( QtyInPurchaseOrderPriceUnit * ( NetPriceAmount ) ) as abap.dec( 23, 2 ) )
      else cast(PurOrdAmountInCompanyCodeCrcy as abap.dec(23,2)) end                                                           as PurOrdAmountInCompanyCodeCrcy, //dmbtr
      //      @Semantics.amount.currencyCode: 'Currency'
      //      cast( ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * curr_to_decfloat_amount( NetPriceAmount ) ) as abap.curr( 13, 2 ) ) as PurchaseOrderAmount,
      //      cast( ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * ( NetPriceAmount ) ) as abap.dec( 23, 2 ) ) as PurchaseOrderAmount,
      cast( ( coalesce(_MaterialDocumentItem.QtyInPurchaseOrderPriceUnit,0) * coalesce(NetPriceAmount,0) ) as abap.dec(23,2) ) as PurchaseOrderAmount,
      //      PurchaseOrderAmount,           //wrbtr
      Currency,                      //waers
      DebitCreditCode,               //shkzg
      PurchaseOrderQuantityUnit,
      OrderPriceUnit,
      CompanyCodeCurrency,
      @ObjectModel.foreignKey.association: '_PurgDocumentItemCategory'
      PurchaseOrderItemCategory, //pstyp
      @Semantics.text: true
      PurchaseOrderItemText,     //txz01
      @Semantics.amount.currencyCode: 'ItemDocumentCurrency'
      @DefaultAggregation: #NONE
      cast( NetPriceAmount as abap.dec( 23, 2 ) )                                                                              as NetPriceAmount, //Added by Sukhwinder
      //      NetPriceAmount,            //netpr
      @Semantics.quantity.unitOfMeasure: 'ItemOrderPriceUnit'
      NetPriceQuantity,          //peinh
      AccountAssignmentCategory, //knttp
      @ObjectModel.foreignKey.association: '_PurgDocumentCategory'
      ItemPurchaseOrderCategory, //webre
      TaxCode,                   //mwskz
      StorageLocation,           //lgort
      ItemDocumentCurrency,
      ItemOrderPriceUnit,
      @ObjectModel.foreignKey.association: '_PurchasingDocumentCategory'
      //  _PurchaseOrder.PurchasingDocumentCategory,                        //bstyp
      //      cast ( 'F' as i_purchasingdocumentcategory.purchasingdocumentcategory  preserving type ) as PurchasingDocumentCategory, //bstyp
      PurchasingDocumentCategory, //bstyp
      @ObjectModel.foreignKey.association: '_PaymentTerms'
      PaymentTerms, //zterm
      @ObjectModel.foreignKey.association: '_CompanyCode'
      CompanyCode, //bukrs
      Supplier,    //lifnr,
      _supplier.BPSupplierName                                                                                                 as SupplierName,
      _supplier.BusinessPartnerPanNumber,
      case when PurchaseOrderItemCategory = '0'
      then cast( '1100' as abap.numc( 4 ) )
      else cast( '1100' as abap.numc( 4 ) ) end                                                                                as secco,

      case when ( cast( cast( substring($session.system_date, 5, 2) as abap.numc( 2 ) ) as abap.int1 ) < 4 )
           then cast( concat( cast( cast( cast( substring($session.system_date, 1, 4) as abap.numc( 4 ) ) as abap.int2 ) - 1 as abap.char( 12 ) ) , '0401') as abap.dats )
           else cast( concat( substring($session.system_date, 1, 4) , '0401') as abap.dats ) end                               as TANExemptDate,

      _MaterialDocumentItem.MaterialDocument,
      _MaterialDocumentItem.MaterialDocumentItem,
      _MaterialDocumentItem.MaterialDocumentYear,
      @Semantics.quantity.unitOfMeasure: 'MatdDeliveryQuantityUnit'
      _MaterialDocumentItem.QuantityInDeliveryQtyUnit                                                                          as MatdQuantityInDeliveryQtyUnit, //lsmng
      _MaterialDocumentItem.DeliveryQuantityUnit                                                                               as MatdDeliveryQuantityUnit,      //lsmeh
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _MaterialDocumentItem.QuantityInEntryUnit,                                                                                                                 //erfmg
      _MaterialDocumentItem.EntryUnit,                                                                                                                           //erfme
      @Semantics.quantity.unitOfMeasure: 'MatdOrderPriceUnit'
      case when _MaterialDocumentItem.OrderPriceUnit = 'TO'
      then ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * 1000 )
      else _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit end                                                               as MatdQtyInPOPriceUnit,          //bpmng

      _MaterialDocumentItem.OrderPriceUnit                                                                                     as MatdOrderPriceUnit,            //bprme

//      case when AccountAssignmentCategory <> 'K' and PurchaseOrderItemCategory = '0'
//      then '4Q'
//      when PurchaseOrderItemCategory = ' ' or PurchaseOrderItemCategory = ''
//      then '4Q'
//      else coalesce( _SupplierWithHoldingTax.WithholdingTaxCode, '' ) end                                                      as WithholdingTaxCode,

     case when AccountAssignmentCategory <> 'K' and PurchaseOrderItemCategory = '0'
          then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
          when PurchaseOrderItemCategory = ' ' or PurchaseOrderItemCategory = ''
          then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
          else coalesce( _SupplierWithHoldingTax.WithholdingTaxCode, '' ) end                                                      as WithholdingTaxCode,


      case when AccountAssignmentCategory <> 'K' and PurchaseOrderItemCategory = '0'
            then '4Q'
            when PurchaseOrderItemCategory = ' ' or PurchaseOrderItemCategory = ''
            then '4Q'
            else coalesce( _SupplierWithHoldingTax.WithholdingTaxType, '' ) end                                                as WithholdingTaxType,

      concat( PurchasingHistoryDocument, PurchasingHistoryDocumentYear )                                                       as yearmblnr,

      _ServiceEntrySheetItem.ServiceEntrySheet,
      _ServiceEntrySheetItem.ServiceEntrySheetItem,
      _MaterialDocumentItem.CostCenter,
      coalesce( GLAccount, _MaterialDocumentItem.GLAccount )                                                                   as GLAccount,
      AssetNo,
      //      _SupplierItem.SupplierInvoice as SupInv,
      //      _SupplierItem.SupplierInvoiceItem as SupInvItem,

      //Associations
      _MaterialDocumentItem,
      _PurchasingDocumentCategory,
      _PurgDocumentItemCategory,
      _CompanyCode,
      _PurgDocumentCategory,
      _PaymentTerms
}
where
      Quantity                               > 0
  and _MaterialDocumentItem.MaterialDocument is not null

union all

select from zi_schdule_agrmnt

association [0..1] to ZI_MIRO_MatDocItem           as _MaterialDocumentItem       on  _MaterialDocumentItem.MaterialDocumentYear = $projection.PurchasingHistoryDocumentYear
                                                                                  and _MaterialDocumentItem.MaterialDocument     = $projection.PurchasingHistoryDocument
                                                                                  and _MaterialDocumentItem.MaterialDocumentItem = $projection.PurchasingHistoryDocumentItem

association [0..1] to I_MaterialDocumentHeader_2   as _MatDoc                     on  _MatDoc.MaterialDocumentYear = $projection.PurchasingHistoryDocumentYear
                                                                                  and _MatDoc.MaterialDocument     = $projection.PurchasingHistoryDocument


association [0..1] to I_Supplier                   as _supplier                   on  _supplier.Supplier = $projection.Supplier

association [1..1] to I_PurchasingDocumentCategory as _PurchasingDocumentCategory on  $projection.PurchasingDocumentCategory = _PurchasingDocumentCategory.PurchasingDocumentCategory

association [0..1] to I_CompanyCode                as _CompanyCode                on  $projection.CompanyCode = _CompanyCode.CompanyCode

association [0..1] to I_PurgDocumentItemCategory   as _PurgDocumentItemCategory   on  $projection.PurchaseOrderItemCategory = _PurgDocumentItemCategory.PurchasingDocumentItemCategory

association [0..1] to I_PaymentTerms               as _PaymentTerms               on  $projection.PaymentTerms = _PaymentTerms.PaymentTerms

association [0..1] to I_PurchasingDocumentCategory as _PurgDocumentCategory       on  $projection.ItemPurchaseOrderCategory = _PurgDocumentCategory.PurchasingDocumentCategory

association [0..1] to I_SupplierWithHoldingTax     as _SupplierWithHoldingTax     on  _SupplierWithHoldingTax.Supplier           = $projection.Supplier
                                                                                  and _SupplierWithHoldingTax.CompanyCode        = $projection.CompanyCode
                                                                                  and _SupplierWithHoldingTax.WithholdingTaxType <> '4Q'
                                                                                  
association [0..1] to I_SupplierWithHoldingTax     as _SupplierWithHoldingTax1     on  _SupplierWithHoldingTax1.Supplier           = $projection.Supplier
                                                                                  and _SupplierWithHoldingTax1.CompanyCode        = $projection.CompanyCode
                                                                                  and _SupplierWithHoldingTax1.WithholdingTaxType = '4Q'                                                                                  

{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key AccountAssignmentNumber,
  key PurchasingHistoryDocumentType, //vgabe
  key PurchasingHistoryDocumentYear, //gjahr
  key PurchasingHistoryDocument,     //belnr
  key PurchasingHistoryDocumentItem, //buzei
      _MaterialDocumentItem.ReferenceDocument                                                                 as DocumentReferenceID, //xblnr
      DocumentDate,                  //bldat
      ReferenceDocument,             //lfbnr
      ReferenceDocumentFiscalYear,   //lfgja
      ReferenceDocumentItem,         //lfpos
      //      PostingDate,                   //budat
      case when _MatDoc.CreationTime between '183000' and '240000'
      then
      dats_add_days(_MatDoc.CreationDate,1,'NULL')
      else
      _MatDoc.CreationDate end                                                                                as PostingDate,
      _MatDoc.CreationDate                                                                                    as MatDocCreateDate,
      _MatDoc.CreationTime                                                                                    as MatDocCreateTime,
      //      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Material', element: 'Material ' } }]
      Material,                      //matnr
      Plant,                         //werks
      GoodsMovementType,             //bwart
      //@Semantics.quantity.unitOfMeasure:'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,     //lsmng
      DeliveryQuantityUnit,          //lsmeh
      //@Semantics.quantity.unitOfMeasure:'PurchaseOrderQuantityUnit'
      _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit                                                       as Quantity,
      //      Quantity, //menge
      //@Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit, //bpmng
      //@Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast(PurOrdAmountInCompanyCodeCrcy as abap.dec(23,2)) as PurOrdAmountInCompanyCodeCrcy, //dmbtr
      //      cast( ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * ( coalesce( curr_to_decfloat_amount( FIRate ), curr_to_decfloat_amount( NetPriceAmount ) ) ) ) as abap.curr( 13, 2 ) ) as PurchaseOrderAmount,
      //      cast( ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * curr_to_decfloat_amount( NetPriceAmount ) ) as abap.curr( 13, 2 ) ) as PurchaseOrderAmount,
//      cast( ( _MaterialDocumentItem.QtyInPurchaseOrderPriceUnit * ( NetPriceAmount ) ) as abap.dec( 23, 2 ) ) as PurchaseOrderAmount,
      cast( ( coalesce(_MaterialDocumentItem.QtyInPurchaseOrderPriceUnit,0) * coalesce(NetPriceAmount,0) ) as abap.dec(23,2) ) as PurchaseOrderAmount,
      //      PurchaseOrderAmount,           //wrbtr
      Currency,                      //waers
      DebitCreditCode,               //shkzg
      PurchaseOrderQuantityUnit,
      OrderPriceUnit,
      CompanyCodeCurrency,

      //@ObjectModel.foreignKey.association: '_PurgDocumentItemCategory'
      PurchaseOrderItemCategory, //pstyp
      //@Semantics.text: true
      PurchaseOrderItemText, //txz01
      //@Semantics.amount.currencyCode: 'ItemDocumentCurrency'
      //@DefaultAggregation: #NONE
      //      NetPriceAmount, //netpr
      cast( NetPriceAmount as abap.dec( 23, 2 ) )                                                             as NetPriceAmount, //Added by Sukhwinder
      //@Semantics.quantity.unitOfMeasure: 'ItemOrderPriceUnit'
      NetPriceQuantity,          //peinh
      AccountAssignmentCategory, //knttp
      //@ObjectModel.foreignKey.association: '_PurgDocumentCategory'
      ItemPurchaseOrderCategory, //webre
      TaxCode,                   //mwskz
      StorageLocation,           //lgort
      ItemDocumentCurrency,
      ItemOrderPriceUnit,
      //@ObjectModel.foreignKey.association: '_PurchasingDocumentCategory'
      //  _PurchaseOrder.PurchasingDocumentCategory,                        //bstyp
      //      cast ( 'F' as i_purchasingdocumentcategory.purchasingdocumentcategory  preserving type ) as PurchasingDocumentCategory, //bstyp
      PurchasingDocumentCategory, //bstyp
      //@ObjectModel.foreignKey.association: '_PaymentTerms'
      PaymentTerms, //zterm
      //@ObjectModel.foreignKey.association: '_CompanyCode'
      CompanyCode, //bukrs
      Supplier,    //lifnr,
      _supplier.BPSupplierName                                                                                as SupplierName,
      _supplier.BusinessPartnerPanNumber,
      case when PurchaseOrderItemCategory = '0'
      then cast( '1100' as abap.numc( 4 ) )
      else cast( '1100' as abap.numc( 4 ) ) end                                                               as secco,

      case when ( cast( cast( substring($session.system_date, 5, 2) as abap.numc( 2 ) ) as abap.int1 ) < 4 )
      then cast( concat( cast( cast( cast( substring($session.system_date, 1, 4) as abap.numc( 4 ) ) as abap.int2 ) - 1 as abap.char( 12 ) ) , '0401') as abap.dats )
      else cast( concat( substring($session.system_date, 1, 4) , '0401') as abap.dats ) end                   as TANExemptDate,

      MaterialDocument,
      MaterialDocumentItem,
      MaterialDocumentYear,
      MatdQuantityInDeliveryQtyUnit,
      MatdDeliveryQuantityUnit,
      QuantityInEntryUnit,
      EntryUnit,
      MatdQtyInPOPriceUnit,
      MatdOrderPriceUnit,

//      case when AccountAssignmentCategory <> 'K' and YY1_PSTYP2_PDI = '0'
//      then '4Q'
//      when YY1_PSTYP2_PDI = ' ' or YY1_PSTYP2_PDI = ''
//      then '4Q'
//      else coalesce( _SupplierWithHoldingTax.WithholdingTaxCode, '' ) end                                     as WithholdingTaxCode,

      case when AccountAssignmentCategory <> 'K' and YY1_PSTYP2_PDI = '0'
      then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
      when YY1_PSTYP2_PDI = ' ' or YY1_PSTYP2_PDI = ''
      then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
      else coalesce( _SupplierWithHoldingTax.WithholdingTaxCode, '' ) end                                     as WithholdingTaxCode,


      case when AccountAssignmentCategory <> 'K' and YY1_PSTYP2_PDI = '0'
      then '4Q'
      when YY1_PSTYP2_PDI = ' ' or YY1_PSTYP2_PDI = ''
      then '4Q'
      else coalesce( _SupplierWithHoldingTax.WithholdingTaxType, '' ) end                                     as WithholdingTaxType,

      concat( PurchasingHistoryDocument, PurchasingHistoryDocumentYear )                                      as yearmblnr,

      cast ('' as abap.char(10))                                                                              as ServiceEntrySheet,
      cast ('00000' as abap.numc(5))                                                                          as ServiceEntrySheetItem,
      _MaterialDocumentItem.CostCenter,
      coalesce( GLAccount, _MaterialDocumentItem.GLAccount )                                                  as GLAccount,
      AssetNo,
      //      @Semantics.amount.currencyCode: 'ItemDocumentCurrency'
      //      sum( _AccountDocItem.AmountInTransactionCurrency )                                                                              as FIAmount,
      //Associations
      _MaterialDocumentItem,
      _PurchasingDocumentCategory,
      _PurgDocumentItemCategory,
      _CompanyCode,
      _PurgDocumentCategory,
      _PaymentTerms

}
where
      Quantity                               > 0
  and _MaterialDocumentItem.MaterialDocument is not null
