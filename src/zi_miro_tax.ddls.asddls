@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax calculation for miro'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_miro_tax
  as select from ZI_MIRO_JOINS

  association [0..*] to zi_miro_supplier_invoice       as _Rseg               on  _Rseg.PurchaseOrder               = $projection.PurchaseOrder
                                                                              and _Rseg.PurchaseOrderItem           = $projection.PurchaseOrderItem
                                                                              and (
                                                                                 _Rseg.ReferenceDocument            = $projection.MaterialDocument
                                                                                 or _Rseg.ReferenceDocument         = $projection.ServiceEntrySheet
                                                                               )
                                                                              and _Rseg.ReferenceDocumentFiscalYear = $projection.MaterialDocumentYear //ReferenceDocumentFiscalYear
                                                                              and (
                                                                                 _Rseg.ReferenceDocumentItem        = $projection.MaterialDocumentItem
                                                                                 or _Rseg.ReferenceDocumentItem5    = $projection.ServiceEntrySheetItem
                                                                               )
                                                                              and _Rseg.IsInvoice                   = 'X'
  association [0..1] to zi_po_tan_sum                  as _POTANExemAmt       on  _POTANExemAmt.PurchaseOrder              = $projection.PurchaseOrder
                                                                              and _POTANExemAmt.PurchaseOrderItem          = $projection.PurchaseOrderItem
  //                                                                              and _POTANExemAmt.TANAccumWithholdingTaxCode = $projection.WithholdingTaxCode
  //                                                                              and _POTANExemAmt.TANAccumWithholdingTaxType = $projection.WithholdingTaxCode
                                                                              and _POTANExemAmt.TANExempWithholdingTaxType = $projection.WithholdingTaxType
                                                                              and _POTANExemAmt.TANExempWithholdingTaxCode = $projection.WithholdingTaxCode

  association [0..1] to zi_po_tan_sum                  as _POTANAccumAmt      on  _POTANAccumAmt.PurchaseOrder              = $projection.PurchaseOrder
                                                                              and _POTANAccumAmt.PurchaseOrderItem          = $projection.PurchaseOrderItem
                                                                              and _POTANAccumAmt.TANAccumWithholdingTaxCode = $projection.WithholdingTaxCode
                                                                              and _POTANAccumAmt.TANAccumWithholdingTaxType = $projection.WithholdingTaxType
  //                                                                              and _POTANAccumAmt.TANExempWithholdingTaxType = $projection.WithholdingTaxCode
  //                                                                              and _POTANAccumAmt.TANExempWithholdingTaxCode = $projection.WithholdingTaxCode


  association [0..1] to I_PurgDocumentItemCategoryText as _POItemCategoryText on  _POItemCategoryText.PurchasingDocumentItemCategory = $projection.PurchaseOrderItemCategory
                                                                              and _POItemCategoryText.Language                       = $session.system_language

  association [0..1] to I_UnitOfMeasure                as _UnitOfMeasure      on  _UnitOfMeasure.UnitOfMeasure = $projection.PurchaseOrderQuantityUnit

  association [0..1] to C_BOMMaterialVH                as _Material           on  _Material.Material = $projection.Material

  association [0..1] to zz1_tax_code1                  as _tax_code1          on  _tax_code1.tax_code = $projection.TaxCode

  association [0..1] to I_ProductPlantBasic            as _ProductPlant       on  _ProductPlant.Product = $projection.Material
                                                                              and _ProductPlant.Plant   = $projection.Plant

  association [0..1] to I_FixedAsset                   as _fixedAsset         on  _fixedAsset.CompanyCode      = $projection.CompanyCode
                                                                              and _fixedAsset.MasterFixedAsset = $projection.AssetNo
                                                                              and _fixedAsset.FixedAsset       = '0000'
                                                                              
  association [0..1] to I_CostCenterText        as _CostCenterTxt on _CostCenterTxt.CostCenter = $projection.CostCenter
                                                                 and _CostCenterTxt.ControllingArea = 'A000'                                                                               
                                                                 and _CostCenterTxt.Language = 'E'                                                                               
                                                                 and _CostCenterTxt.ValidityEndDate = '99991231'                                                                               
  //  association [0..1] to I_JournalEntry                 as _journalentry       on  _journalentry.OriginalReferenceDocument = $projection.yearmblnr
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key AccountAssignmentNumber,
  key PurchasingHistoryDocumentType,
  key PurchasingHistoryDocumentYear,
  key PurchasingHistoryDocument,
  key PurchasingHistoryDocumentItem,
  key ServiceEntrySheet,
  key ServiceEntrySheetItem,
      DocumentReferenceID,
      DocumentDate,
      ReferenceDocument,
      ReferenceDocumentFiscalYear,
      ReferenceDocumentItem,
      //      coalesce( max( _journalentry.PostingDate ) ,PostingDate )                                                                                                             as PostingDate,
      PostingDate,
      Material,
      _Material.MaterialDescription,
      Plant,
      _ProductPlant.ConsumptionTaxCtrlCode,
      GoodsMovementType,
      @Semantics.quantity.unitOfMeasure:'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,
      DeliveryQuantityUnit,
      @Semantics.quantity.unitOfMeasure:'PurchaseOrderQuantityUnit'
      Quantity,
      @Semantics.quantity.unitOfMeasure:'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      PurOrdAmountInCompanyCodeCrcy,
//      @Semantics.amount.currencyCode: 'Currency'
      cast(PurchaseOrderAmount as abap.dec(13,2)) as PurchaseOrderAmount,
      Currency,
      DebitCreditCode,
      PurchaseOrderQuantityUnit,
      OrderPriceUnit,
      CompanyCodeCurrency,
      PurchaseOrderItemCategory,
      _POItemCategoryText.PurgDocItemCategoryName,
      PurchaseOrderItemText,
      @Semantics.amount.currencyCode: 'Currency'
      NetPriceAmount,
      NetPriceQuantity,
      AccountAssignmentCategory,
      ItemPurchaseOrderCategory,
      TaxCode,
      StorageLocation,
      ItemDocumentCurrency,
      ItemOrderPriceUnit,
      PurchasingDocumentCategory,
      PaymentTerms,
      CompanyCode,
      Supplier,
      SupplierName,
      @Semantics.quantity.unitOfMeasure: 'MatdDeliveryQuantityUnit'
      cast( ( MatdQuantityInDeliveryQtyUnit - MatdQtyInPOPriceUnit ) as abap.quan( 18, 3 ) )                                                                                as short,

      secco,
      MaterialDocument,
      MaterialDocumentItem,
      MaterialDocumentYear,
      @Semantics.quantity.unitOfMeasure: 'MatdDeliveryQuantityUnit'
      MatdQuantityInDeliveryQtyUnit,
      MatdDeliveryQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'MatdOrderPriceUnit'
      MatdQtyInPOPriceUnit,
      MatdOrderPriceUnit,
      TANExemptDate,
      BusinessPartnerPanNumber,
      WithholdingTaxCode,
      WithholdingTaxType,
//      @Semantics.amount.currencyCode: 'Currency'
      coalesce( _POTANAccumAmt.IN_AccumulationAmount, cast( 0 as abap.dec( 23, 2 ) ) )                                                                                     as IN_AccumulationAmount,
//      @Semantics.amount.currencyCode: 'Currency'
      _POTANExemAmt.IN_ThresholdAmount,
//      @Semantics.amount.currencyCode: 'Currency'
      ( coalesce( _POTANExemAmt.IN_ThresholdAmount, cast( 0 as abap.dec( 23, 2 ) ) ) - coalesce( _POTANAccumAmt.IN_AccumulationAmount, cast( 0 as abap.dec( 23, 2 ) ) ) ) as IN_ThresholdAmountDiff,
      //      SupplierInvoice,
      //      FiscalYear,
      //      SupplierInvoiceItem,
      //      AssignmentReference,
      //      SupplierInvoiceStatus,
      //      SupplierInvoiceIDByInvcgParty,
      //      SupplierInvDocumentDate,

      coalesce( _Rseg.SupplierInvoice, '' )                                                                                                                                 as SupplierInvoice,
      coalesce( _Rseg.FiscalYear, '0000' )                                                                                                                                  as FiscalYear,
      _Rseg.SupplierInvoiceItem,
      substring( _Rseg.AssignmentReference, 1, 10)                                                                                                                          as AssignmentReference,
      case
      when _Rseg.SupplierInvoiceStatus = '1' then 'Defined for background verification'
      when _Rseg.SupplierInvoiceStatus = '2' then 'Deleted'
      when _Rseg.SupplierInvoiceStatus = '3' then 'With Errors'
      when _Rseg.SupplierInvoiceStatus = '4' then 'Correct (posted, not completed)'
      when _Rseg.SupplierInvoiceStatus = '5' and  _Rseg.ReverseDocument = '' then 'Posted'
      when _Rseg.SupplierInvoiceStatus = '5' and  _Rseg.ReverseDocument <> '' then 'Cancelled'
      when _Rseg.SupplierInvoiceStatus = 'A' then 'Parked'
      when _Rseg.SupplierInvoiceStatus = 'B' then 'Parked and completed'
      when _Rseg.SupplierInvoiceStatus = 'C' then 'Parked and held'
      when _Rseg.SupplierInvoiceStatus = 'D' then 'Entered and held'
      when _Rseg.SupplierInvoiceStatus = 'E' then 'Parked and released'
      else _Rseg.SupplierInvoiceStatus end                                                                                                                                  as SupplierInvoiceStatus,
      _Rseg.SupplierInvoiceStatus                                                                                                                                           as SupplierInvoiceStatusNum,

      _Rseg.SupplierInvoiceIDByInvcgParty,
      _Rseg.DocumentDate                                                                                                                                                    as SupplierInvDocumentDate,
      _UnitOfMeasure.UnitOfMeasure_E,

      cast( _tax_code1.cgst as abap.dec(13,2) )                                                                                                                             as cgst_rate,
//      @Semantics.amount.currencyCode: 'Currency'
      cast( division( ( cast( PurchaseOrderAmount as abap.dec(13, 2) ) *
                ( fltp_to_dec( _tax_code1.cgst as abap.dec(12, 2) ) ) ), 100, 2 ) as abap.dec( 13, 2 ) )                                                                   as cgst_value,
      cast( _tax_code1.sgst as abap.dec(13,2) )                                                                                                                             as sgst_rate,
//      @Semantics.amount.currencyCode: 'Currency'
      cast( division( ( cast( PurchaseOrderAmount as abap.dec(13, 2) ) *
                ( fltp_to_dec( _tax_code1.sgst as abap.dec(12, 2) ) ) ), 100, 2 ) as abap.dec( 13, 2 ) )                                                                   as sgst_value,
      cast( _tax_code1.igst as abap.dec(13,2) )                                                                                                                             as igst_rate,
//      @Semantics.amount.currencyCode: 'Currency'
      cast( division( ( cast( PurchaseOrderAmount as abap.dec(13, 2) ) *
                ( fltp_to_dec( _tax_code1.igst as abap.dec(12, 2) ) ) ), 100, 2 ) as abap.dec( 13, 2 ) )                                                                   as igst_value,

      yearmblnr,
      CostCenter,
      _CostCenterTxt.CostCenterDescription,
      GLAccount,
      AssetNo,
      _fixedAsset.FixedAssetDescription,

      /* Associations */
      _CompanyCode,
      _MaterialDocumentItem,
      _PaymentTerms,
      _PurchasingDocumentCategory,
      _PurgDocumentCategory,
      _PurgDocumentItemCategory,
      _POItemCategoryText
}

//group by
//  PurchaseOrder,
//  PurchaseOrderItem,
//  AccountAssignmentNumber,
//  PurchasingHistoryDocumentType,
//  PurchasingHistoryDocumentYear,
//  PurchasingHistoryDocument,
//  PurchasingHistoryDocumentItem,
//  ServiceEntrySheet,
//  ServiceEntrySheetItem,
//  _Rseg.SupplierInvoice,
//  _Rseg.FiscalYear,
//  _Rseg.SupplierInvoiceItem,
//  _Rseg.SupplierInvoiceIDByInvcgParty,
//  _Rseg.DocumentDate,
//  _UnitOfMeasure.UnitOfMeasure_E,
//  DocumentReferenceID,
//  DocumentDate,
//  ReferenceDocument,
//  ReferenceDocumentFiscalYear,
//  ReferenceDocumentItem,
//  PostingDate,
//  Material,
//  _Material.MaterialDescription,
//  Plant,
//  _ProductPlant.ConsumptionTaxCtrlCode,
//  GoodsMovementType,
//  QuantityInDeliveryQtyUnit,
//  DeliveryQuantityUnit,
//  Quantity,
//  QtyInPurchaseOrderPriceUnit,
//  PurOrdAmountInCompanyCodeCrcy,
//  PurchaseOrderAmount,
//  Currency,
//  DebitCreditCode,
//  PurchaseOrderQuantityUnit,
//  OrderPriceUnit,
//  CompanyCodeCurrency,
//  PurchaseOrderItemCategory,
//  _POItemCategoryText.PurgDocItemCategoryName,
//  PurchaseOrderItemText,
//  NetPriceAmount,
//  NetPriceQuantity,
//  _POTANAccumAmt.IN_AccumulationAmount,
//  _POTANAccumAmt.IN_ThresholdAmount,
//  AccountAssignmentCategory,
//  ItemPurchaseOrderCategory,
//  TaxCode,
//  WithholdingTaxCode,
//  WithholdingTaxType,
//  StorageLocation,
//  ItemDocumentCurrency,
//  ItemOrderPriceUnit,
//  PurchasingDocumentCategory,
//  PaymentTerms,
//  CompanyCode,
//  Supplier,
//  SupplierName,
//  secco,
//  MaterialDocument,
//  MaterialDocumentItem,
//  MaterialDocumentYear,
//  MatdQuantityInDeliveryQtyUnit,
//  MatdQtyInPOPriceUnit,
//  _Rseg.AssignmentReference,
//  _Rseg.SupplierInvoiceStatus,
//  MatdDeliveryQuantityUnit,
//  QuantityInEntryUnit,
//  EntryUnit,
//  MatdOrderPriceUnit,
//  BusinessPartnerPanNumber,
//  _POTANExemAmt.IN_ThresholdAmount,
//  TANExemptDate,
//  _Rseg.ReverseDocument,
//  _tax_code1.cgst,
//  _tax_code1.igst,
//  _tax_code1.sgst,
//  yearmblnr
