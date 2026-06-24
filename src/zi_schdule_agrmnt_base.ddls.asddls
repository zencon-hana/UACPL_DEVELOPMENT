@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for schdule agreement'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity zi_schdule_agrmnt_base
  as select from    I_SchedgAgrmtItmApi01

    left outer join I_MaterialDocumentItem_2 as _MaterialDocItem on  _MaterialDocItem.PurchaseOrder     = I_SchedgAgrmtItmApi01.SchedulingAgreement
                                                                 and _MaterialDocItem.PurchaseOrderItem = I_SchedgAgrmtItmApi01.SchedulingAgreementItem
                                                                 and _MaterialDocItem.GoodsMovementType = '101'
  association [1..1] to I_PurchaseOrderItemAPI01 as _POItem on  _POItem.PurchaseOrder     = $projection.PurchaseOrder
                                                            and _POItem.PurchaseOrderItem = $projection.PurchaseOrderItem
                                                            and _POItem.PurchasingDocumentDeletionCode = ' '

{
  key I_SchedgAgrmtItmApi01.SchedulingAgreement                                                                                                               as PurchaseOrder,
  key I_SchedgAgrmtItmApi01.SchedulingAgreementItem                                                                                                           as PurchaseOrderItem,
  key cast( '00' as abap.numc( 2 ) )                                                                                                                          as AccountAssignmentNumber,
  key cast( '1'  as abap.char( 1 ) )                                                                                                                          as PurchasingHistoryDocumentType, //vgabe
  key coalesce(_MaterialDocItem.MaterialDocumentYear, '0000' )                                                                                                as PurchasingHistoryDocumentYear,
  key coalesce(_MaterialDocItem.MaterialDocument, '' )                                                                                                        as PurchasingHistoryDocument,
  key coalesce(_MaterialDocItem.MaterialDocumentItem, '0000' )                                                                                                as PurchasingHistoryDocumentItem,
      cast( ' ' as abap.char( 16 ) )                                                                                                                          as DocumentReferenceID,
      _MaterialDocItem.DocumentDate,
      _MaterialDocItem.InvtryMgmtReferenceDocument                                                                                                            as ReferenceDocument,
      _MaterialDocItem.ReferenceDocumentFiscalYear                                                                                                            as ReferenceDocumentFiscalYear,
      _MaterialDocItem.InvtryMgmtRefDocumentItem                                                                                                              as ReferenceDocumentItem,
      _MaterialDocItem.PostingDate,
      _MaterialDocItem.GoodsMovementType,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _MaterialDocItem.QuantityInDeliveryQtyUnit,
      _MaterialDocItem.DeliveryQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _MaterialDocItem.QuantityInBaseUnit                                                                                                                     as Quantity,
      //      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      //      _MaterialDocItem.QuantityInBaseUnit                                                                        as Quantity,
      _MaterialDocItem.MaterialBaseUnit                                                                                                                       as PurchaseOrderQuantityUnit,
      _MaterialDocItem.OrderPriceUnit,
      @Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      sum( case when _MaterialDocItem.DebitCreditCode = 'H'
      then ( _MaterialDocItem.QtyInPurchaseOrderPriceUnit - _MaterialDocItem.QtyInPurchaseOrderPriceUnit )
      else ( _MaterialDocItem.QtyInPurchaseOrderPriceUnit + _MaterialDocItem.QtyInPurchaseOrderPriceUnit ) end )                                              as QtyInPurchaseOrderPriceUnit, //bpmng

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case when _MaterialDocItem.DebitCreditCode = 'H'
      then ( _MaterialDocItem.TotalGoodsMvtAmtInCCCrcy - _MaterialDocItem.TotalGoodsMvtAmtInCCCrcy )
      else ( _MaterialDocItem.TotalGoodsMvtAmtInCCCrcy + _MaterialDocItem.TotalGoodsMvtAmtInCCCrcy ) end )                                                    as PurOrdAmountInCompanyCodeCrcy, //dmbtr
      _MaterialDocItem.DebitCreditCode,
      _MaterialDocItem.CompanyCodeCurrency,
      I_SchedgAgrmtItmApi01.CompanyCode,
      I_SchedgAgrmtItmApi01.PurchasingDocumentCategory,
      I_SchedgAgrmtItmApi01.PurchasingDocumentItemText                                                                                                        as PurchaseOrderItemText,
      I_SchedgAgrmtItmApi01.Material,
      I_SchedgAgrmtItmApi01.ManufacturerMaterial,
      I_SchedgAgrmtItmApi01.SupplierMaterialNumber,
      I_SchedgAgrmtItmApi01.MaterialGroup,
      I_SchedgAgrmtItmApi01.Plant,
      I_SchedgAgrmtItmApi01.ManualDeliveryAddressID,
      I_SchedgAgrmtItmApi01.ReferenceDeliveryAddressID,
      I_SchedgAgrmtItmApi01.IncotermsClassification,
      I_SchedgAgrmtItmApi01.IncotermsTransferLocation,
      I_SchedgAgrmtItmApi01.OrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      I_SchedgAgrmtItmApi01.ItemNetWeight,
      I_SchedgAgrmtItmApi01.WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      I_SchedgAgrmtItmApi01.TargetQuantity,
      I_SchedgAgrmtItmApi01.PurchaseRequisition,
      I_SchedgAgrmtItmApi01.PurchaseRequisitionItem,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      I_SchedgAgrmtItmApi01.SchedAgrmtAgreedCumQty,
      I_SchedgAgrmtItmApi01.SchedAgrmtCumQtyReconcileDate,
      I_SchedgAgrmtItmApi01.ItemLastTransmissionDate,
      I_SchedgAgrmtItmApi01.NoDaysReminder1,
      I_SchedgAgrmtItmApi01.NoDaysReminder2,
      I_SchedgAgrmtItmApi01.NoDaysReminder3,
      I_SchedgAgrmtItmApi01.SupplierConfirmationControlKey,
      I_SchedgAgrmtItmApi01.PurgDocOrderAcknNumber,
      I_SchedgAgrmtItmApi01.RequirementTracking,
      I_SchedgAgrmtItmApi01.IsOrderAcknRqd,
      I_SchedgAgrmtItmApi01.PurgDocEstimatedPrice,
      I_SchedgAgrmtItmApi01.PriceIsToBePrinted,
      I_SchedgAgrmtItmApi01.AccountAssignmentCategory,
      I_SchedgAgrmtItmApi01.YY1_PSTYP2_PDI,
      _POItem.PurchaseOrderItemCategory,
      I_SchedgAgrmtItmApi01.DocumentCurrency                                                                                                                  as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      cast( ( get_numeric_value( I_SchedgAgrmtItmApi01.NetPriceAmount ) *  get_numeric_value( _MaterialDocItem.QuantityInBaseUnit ) ) as abap.curr( 13, 2 ) ) as PurchaseOrderAmount,
      @Semantics.amount.currencyCode: 'Currency'
      cast( get_numeric_value( I_SchedgAgrmtItmApi01.NetPriceAmount ) as abap.curr( 13, 2 ) )                                                                 as dummyamt,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      cast( ( get_numeric_value( I_SchedgAgrmtItmApi01.NetPriceQuantity ) ) as abap.quan( 13, 2 ) )                                                           as dummyqty,
      // Quantity * rate difference
      @Semantics.amount.currencyCode: 'ItemDocumentCurrency'
//      cast(I_SchedgAgrmtItmApi01.NetPriceAmount as abap.dec(23,2)) as NetPriceAmount,
      I_SchedgAgrmtItmApi01.NetPriceAmount,
      I_SchedgAgrmtItmApi01.DocumentCurrency                                                                                                                  as ItemDocumentCurrency,
      I_SchedgAgrmtItmApi01.NetPriceQuantity,
      I_SchedgAgrmtItmApi01.OrderPriceUnit                                                                                                                    as ItemOrderPriceUnit,
      I_SchedgAgrmtItmApi01.ProductType,
      I_SchedgAgrmtItmApi01.MaterialType,
      I_SchedgAgrmtItmApi01.StorageLocation,
      I_SchedgAgrmtItmApi01.IsInfoRecordUpdated,
      I_SchedgAgrmtItmApi01.PurchasingInfoRecord,
      I_SchedgAgrmtItmApi01.OrdPriceUnitToOrderUnitDnmntr,
      I_SchedgAgrmtItmApi01.OrderPriceUnitToOrderUnitNmrtr,
      I_SchedgAgrmtItmApi01.PurchasingDocumentDeletionCode,
      I_SchedgAgrmtItmApi01.UnderdelivTolrtdLmtRatioInPct,
      I_SchedgAgrmtItmApi01.OverdelivTolrtdLmtRatioInPct,
      I_SchedgAgrmtItmApi01.UnlimitedOverdeliveryIsAllowed,
      I_SchedgAgrmtItmApi01.StockType,
      I_SchedgAgrmtItmApi01.TaxCode,
      I_SchedgAgrmtItmApi01.ShippingInstruction,
      I_SchedgAgrmtItmApi01.IsInfoAtRegistration,
      I_SchedgAgrmtItmApi01.GoodsReceiptIsExpected,
      I_SchedgAgrmtItmApi01.GoodsReceiptIsNonValuated,
      I_SchedgAgrmtItmApi01.InvoiceIsExpected,
      I_SchedgAgrmtItmApi01.InvoiceIsGoodsReceiptBased                                                                                                        as ItemPurchaseOrderCategory,
      I_SchedgAgrmtItmApi01.EvaldRcptSettlmtIsAllowed,
      I_SchedgAgrmtItmApi01.MinRemainingShelfLife,
      I_SchedgAgrmtItmApi01.QualityMgmtCtrlKey,
      I_SchedgAgrmtItmApi01.QualityCertificateType,
      I_SchedgAgrmtItmApi01.SchedAgrmtCumulativeQtyControl,
      I_SchedgAgrmtItmApi01.CumulativeQuantityIsNotSent,
      I_SchedgAgrmtItmApi01.SchedgAgrmtRelCreationProfile,
      I_SchedgAgrmtItmApi01.IsRelevantForJITDelivSchedule,
      I_SchedgAgrmtItmApi01.NextFcstDelivSchedSendingDate,
      I_SchedgAgrmtItmApi01.NextJITDelivSchedSendingDate,
      I_SchedgAgrmtItmApi01.ScheduleLineFirmOrderInDays,
      I_SchedgAgrmtItmApi01.SchedLineSemiFirmOrderInDays,
      I_SchedgAgrmtItmApi01.FirmTradeOffZoneBindMRP,
      I_SchedgAgrmtItmApi01._SchedgAgrmtHdrAPI01.PaymentTerms,
      I_SchedgAgrmtItmApi01._SchedgAgrmtHdrAPI01.Supplier,
      _MaterialDocItem.MaterialDocument,
      _MaterialDocItem.MaterialDocumentItem,
      _MaterialDocItem.MaterialDocumentYear,
      @Semantics.quantity.unitOfMeasure: 'MatdDeliveryQuantityUnit'
      _MaterialDocItem.QuantityInDeliveryQtyUnit                                                                                                              as MatdQuantityInDeliveryQtyUnit, //lsmng
      _MaterialDocItem.DeliveryQuantityUnit                                                                                                                   as MatdDeliveryQuantityUnit,      //lsmeh
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _MaterialDocItem.QuantityInEntryUnit,                                                                                                                                                     //erfmg
      _MaterialDocItem.EntryUnit,                                                                                                                                                               //erfme

      @Semantics.quantity.unitOfMeasure: 'MatdOrderPriceUnit'
      case when _MaterialDocItem.OrderPriceUnit = 'TO'
      then ( _MaterialDocItem.QtyInPurchaseOrderPriceUnit * 1000 )
      else _MaterialDocItem.QtyInPurchaseOrderPriceUnit end                                                                                                   as MatdQtyInPOPriceUnit,          //bpmng

      _MaterialDocItem.OrderPriceUnit                                                                                                                         as MatdOrderPriceUnit,            //bprme
      concat( _MaterialDocItem.MaterialDocument, _MaterialDocItem.MaterialDocumentYear )                                                                      as MblnrYear,


      /* Associations */
      I_SchedgAgrmtItmApi01._SchedgAgrmtHdrAPI01
}
where I_SchedgAgrmtItmApi01.PurchasingDocumentDeletionCode = ' '
group by
  I_SchedgAgrmtItmApi01.SchedulingAgreement,
  I_SchedgAgrmtItmApi01.SchedulingAgreementItem,
  _MaterialDocItem.GoodsMovementType,
  _MaterialDocItem.MaterialDocumentYear,
  _MaterialDocItem.MaterialDocument,
  _MaterialDocItem.MaterialDocumentItem,

  _MaterialDocItem.InvtryMgmtReferenceDocument,
  _MaterialDocItem.ReferenceDocumentFiscalYear,
  _MaterialDocItem.InvtryMgmtRefDocumentItem,
  _MaterialDocItem.PostingDate,
  _MaterialDocItem.GoodsMovementType,
  _MaterialDocItem.QuantityInDeliveryQtyUnit,
  _MaterialDocItem.DeliveryQuantityUnit,
  _MaterialDocItem.QuantityInBaseUnit,
  _MaterialDocItem.MaterialBaseUnit,
  _MaterialDocItem.QtyInPurchaseOrderPriceUnit,
  _MaterialDocItem.OrderPriceUnit,
  I_SchedgAgrmtItmApi01.CompanyCode,
  I_SchedgAgrmtItmApi01.PurchasingDocumentCategory,
  I_SchedgAgrmtItmApi01.PurchasingDocumentItemText,
  I_SchedgAgrmtItmApi01.Material,
  I_SchedgAgrmtItmApi01.ManufacturerMaterial,
  I_SchedgAgrmtItmApi01.SupplierMaterialNumber,
  I_SchedgAgrmtItmApi01.MaterialGroup,
  I_SchedgAgrmtItmApi01.Plant,
  I_SchedgAgrmtItmApi01.ManualDeliveryAddressID,
  I_SchedgAgrmtItmApi01.ReferenceDeliveryAddressID,
  I_SchedgAgrmtItmApi01.IncotermsClassification,
  I_SchedgAgrmtItmApi01.IncotermsTransferLocation,
  I_SchedgAgrmtItmApi01.OrderQuantityUnit,
  I_SchedgAgrmtItmApi01.ItemNetWeight,
  I_SchedgAgrmtItmApi01.WeightUnit,
  I_SchedgAgrmtItmApi01.TargetQuantity,
  I_SchedgAgrmtItmApi01.PurchaseRequisition,
  I_SchedgAgrmtItmApi01.PurchaseRequisitionItem,
  I_SchedgAgrmtItmApi01.SchedAgrmtAgreedCumQty,
  I_SchedgAgrmtItmApi01.SchedAgrmtCumQtyReconcileDate,
  I_SchedgAgrmtItmApi01.ItemLastTransmissionDate,
  I_SchedgAgrmtItmApi01.NoDaysReminder1,
  I_SchedgAgrmtItmApi01.NoDaysReminder2,
  I_SchedgAgrmtItmApi01.NoDaysReminder3,
  I_SchedgAgrmtItmApi01.SupplierConfirmationControlKey,
  I_SchedgAgrmtItmApi01.PurgDocOrderAcknNumber,
  I_SchedgAgrmtItmApi01.RequirementTracking,
  I_SchedgAgrmtItmApi01.IsOrderAcknRqd,
  I_SchedgAgrmtItmApi01.PurgDocEstimatedPrice,
  I_SchedgAgrmtItmApi01.PriceIsToBePrinted,
  I_SchedgAgrmtItmApi01.AccountAssignmentCategory,
  I_SchedgAgrmtItmApi01.YY1_PSTYP2_PDI,
  I_SchedgAgrmtItmApi01.DocumentCurrency,
  I_SchedgAgrmtItmApi01.NetPriceAmount,
  I_SchedgAgrmtItmApi01.NetPriceQuantity,
  I_SchedgAgrmtItmApi01.ProductType,
  I_SchedgAgrmtItmApi01.MaterialType,
  I_SchedgAgrmtItmApi01.StorageLocation,
  I_SchedgAgrmtItmApi01.IsInfoRecordUpdated,
  I_SchedgAgrmtItmApi01.PurchasingInfoRecord,
  I_SchedgAgrmtItmApi01.OrdPriceUnitToOrderUnitDnmntr,
  I_SchedgAgrmtItmApi01.OrderPriceUnitToOrderUnitNmrtr,
  I_SchedgAgrmtItmApi01.PurchasingDocumentDeletionCode,
  I_SchedgAgrmtItmApi01.UnderdelivTolrtdLmtRatioInPct,
  I_SchedgAgrmtItmApi01.OverdelivTolrtdLmtRatioInPct,
  I_SchedgAgrmtItmApi01.UnlimitedOverdeliveryIsAllowed,
  I_SchedgAgrmtItmApi01.StockType,
  I_SchedgAgrmtItmApi01.TaxCode,
  I_SchedgAgrmtItmApi01.ShippingInstruction,
  I_SchedgAgrmtItmApi01.IsInfoAtRegistration,
  I_SchedgAgrmtItmApi01.GoodsReceiptIsExpected,
  I_SchedgAgrmtItmApi01.GoodsReceiptIsNonValuated,
  I_SchedgAgrmtItmApi01.InvoiceIsExpected,
  I_SchedgAgrmtItmApi01.InvoiceIsGoodsReceiptBased,
  I_SchedgAgrmtItmApi01.EvaldRcptSettlmtIsAllowed,
  I_SchedgAgrmtItmApi01.MinRemainingShelfLife,
  I_SchedgAgrmtItmApi01.QualityMgmtCtrlKey,
  I_SchedgAgrmtItmApi01.QualityCertificateType,
  I_SchedgAgrmtItmApi01.SchedAgrmtCumulativeQtyControl,
  I_SchedgAgrmtItmApi01.CumulativeQuantityIsNotSent,
  I_SchedgAgrmtItmApi01.SchedgAgrmtRelCreationProfile,
  I_SchedgAgrmtItmApi01.IsRelevantForJITDelivSchedule,
  I_SchedgAgrmtItmApi01.NextFcstDelivSchedSendingDate,
  I_SchedgAgrmtItmApi01.NextJITDelivSchedSendingDate,
  I_SchedgAgrmtItmApi01.ScheduleLineFirmOrderInDays,
  I_SchedgAgrmtItmApi01.SchedLineSemiFirmOrderInDays,
  I_SchedgAgrmtItmApi01.FirmTradeOffZoneBindMRP,
  _MaterialDocItem.QuantityInEntryUnit,                                                                                                                                                         //erfmg
  _MaterialDocItem.EntryUnit,
  I_SchedgAgrmtItmApi01.OrderPriceUnit,
  _MaterialDocItem.DocumentDate,
  _MaterialDocItem.CompanyCodeCurrency,
  _MaterialDocItem.DebitCreditCode,
  I_SchedgAgrmtItmApi01._SchedgAgrmtHdrAPI01.PaymentTerms,
  I_SchedgAgrmtItmApi01._SchedgAgrmtHdrAPI01.Supplier,
  _POItem.PurchaseOrderItemCategory
