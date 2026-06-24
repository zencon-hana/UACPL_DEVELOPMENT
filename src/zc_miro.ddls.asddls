@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Miro root view'

define root view entity ZC_MIRO
  as select from zi_miro_tax
{

  key PurchaseOrder,
  key PurchaseOrderItem,
  key AccountAssignmentNumber,
  key PurchasingHistoryDocumentType,
  key PurchasingHistoryDocumentYear,
  key PurchasingHistoryDocument,
  key PurchasingHistoryDocumentItem,
  key ServiceEntrySheet,
      @EndUserText.label: 'Service entry sheet item no.'
  key ServiceEntrySheetItem,
      @Consumption.semanticObject: 'SupplierInvoice'
      @EndUserText.label: 'Bill Passing number'
  key SupplierInvoice,
  key FiscalYear,
      @EndUserText.label: 'Withholding tax code'
  key WithholdingTaxCode,
      @EndUserText.label: 'Withholding tax type'
  key WithholdingTaxType,
      @EndUserText.label: 'Vendor invoice no.'
      DocumentReferenceID,
      DocumentDate,
      ReferenceDocument,
      ReferenceDocumentFiscalYear,
      ReferenceDocumentItem,
      @EndUserText.label: 'Posting date'
      PostingDate,
      Material,
      MaterialDescription,
      Plant,
      @EndUserText.label: 'HSN Code'
      ConsumptionTaxCtrlCode,
      GoodsMovementType,
      QuantityInDeliveryQtyUnit,
      DeliveryQuantityUnit,
      Quantity,
      QtyInPurchaseOrderPriceUnit,
      PurOrdAmountInCompanyCodeCrcy,
      @EndUserText.label: 'Basic value'
      PurchaseOrderAmount,
      @EndUserText.label: 'PO Currency'
      Currency,
      DebitCreditCode,
      @EndUserText.label: 'PO quantity unit'
      PurchaseOrderQuantityUnit,
      @EndUserText.label: 'PO price unit'
      OrderPriceUnit,
      @EndUserText.label: 'Company code Currency'
      CompanyCodeCurrency,
      PurchaseOrderItemCategory,
      @EndUserText.label: 'PO Item Category Desc.'
      PurgDocItemCategoryName,
      PurchaseOrderItemText,
      NetPriceAmount,
      NetPriceQuantity,
      @EndUserText.label: 'Accumulated Amount'
      IN_AccumulationAmount,
      @EndUserText.label: 'Exem. Threshold Amount'
      IN_ThresholdAmount,
      @EndUserText.label: 'Threshold diff. Amount'
      IN_ThresholdAmountDiff,
      AccountAssignmentCategory,
      ItemPurchaseOrderCategory,
      TaxCode,
      StorageLocation,
      @EndUserText.label: 'PO item Currency'
      ItemDocumentCurrency,
      @EndUserText.label: 'PO item price unit'
      ItemOrderPriceUnit,
      PurchasingDocumentCategory,
      PaymentTerms,
      CompanyCode,
      Supplier,
      SupplierName,
      short,
      secco,
      MaterialDocument,
      MaterialDocumentItem,
      MaterialDocumentYear,

      @EndUserText.label: 'Material Doc. Del. Note Quantity'
      MatdQuantityInDeliveryQtyUnit,
      @EndUserText.label: 'Material Doc. Delivery Qty Unit'
      MatdDeliveryQuantityUnit,
      QuantityInEntryUnit,
      EntryUnit,
      MatdQtyInPOPriceUnit,
      MatdOrderPriceUnit,
      @EndUserText.label: 'Bill Passing Item'
      SupplierInvoiceItem,
      @EndUserText.label: 'Account assignment category'
      AssignmentReference,
      @EndUserText.label: 'Bill Passing Status'
      SupplierInvoiceStatus,
      @EndUserText.label: 'Bill Passing Status No'
      SupplierInvoiceStatusNum,
      SupplierInvoiceIDByInvcgParty,
      SupplierInvDocumentDate,
      UnitOfMeasure_E,
      @EndUserText.label: 'CGST rate'
      cgst_rate,
      @EndUserText.label: 'CGST value'
      cgst_value,
      @EndUserText.label: 'SGST rate'
      sgst_rate,
      @EndUserText.label: 'SGST value'
      sgst_value,
      @EndUserText.label: 'IGST rate'
      igst_rate,
      @EndUserText.label: 'IGST value'
      igst_value,
      @EndUserText.label: 'Total amount'
//      @Semantics.amount.currencyCode: 'Currency'
      ( PurchaseOrderAmount + cgst_value + sgst_value + igst_value ) as totalAmount,
      CostCenter,
      CostCenterDescription,
      GLAccount,
      AssetNo,
      FixedAssetDescription,

      /* Associations */
      _CompanyCode,
      _MaterialDocumentItem,
      _PaymentTerms,
      _PurchasingDocumentCategory,
      _PurgDocumentCategory,
      _PurgDocumentItemCategory
}

group by
  PurchaseOrder,
  PurchaseOrderItem,
  AccountAssignmentNumber,
  PurchasingHistoryDocumentType,
  PurchasingHistoryDocumentYear,
  PurchasingHistoryDocument,
  PurchasingHistoryDocumentItem,
  ServiceEntrySheet,
  ServiceEntrySheetItem,
  SupplierInvoice,
  FiscalYear,
  DocumentReferenceID,
  DocumentDate,
  ReferenceDocument,
  ReferenceDocumentFiscalYear,
  ReferenceDocumentItem,
  PostingDate,
  Material,
  MaterialDescription,
  Plant,
  ConsumptionTaxCtrlCode,
  GoodsMovementType,
  QuantityInDeliveryQtyUnit,
  DeliveryQuantityUnit,
  Quantity,
  QtyInPurchaseOrderPriceUnit,
  PurOrdAmountInCompanyCodeCrcy,
  PurchaseOrderAmount,
  Currency,
  DebitCreditCode,
  PurchaseOrderQuantityUnit,
  OrderPriceUnit,
  CompanyCodeCurrency,
  PurchaseOrderItemCategory,
  PurgDocItemCategoryName,
  PurchaseOrderItemText,
  NetPriceAmount,
  NetPriceQuantity,
  IN_AccumulationAmount,
  IN_ThresholdAmount,
  IN_ThresholdAmountDiff,
  AccountAssignmentCategory,
  ItemPurchaseOrderCategory,
  TaxCode,
  WithholdingTaxCode,
  WithholdingTaxType,
  StorageLocation,
  ItemDocumentCurrency,
  ItemOrderPriceUnit,
  PurchasingDocumentCategory,
  PaymentTerms,
  CompanyCode,
  Supplier,
  SupplierName,
  short,
  secco,
  MaterialDocument,
  MaterialDocumentItem,
  MaterialDocumentYear,
  MatdQuantityInDeliveryQtyUnit,
  MatdDeliveryQuantityUnit,
  QuantityInEntryUnit,
  EntryUnit,
  MatdQtyInPOPriceUnit,
  MatdOrderPriceUnit,
  SupplierInvoiceItem,
  AssignmentReference,
  SupplierInvoiceStatus,
  SupplierInvoiceStatusNum,
  SupplierInvoiceIDByInvcgParty,
  SupplierInvDocumentDate,
  UnitOfMeasure_E,
  cgst_rate,
  cgst_value,
  sgst_rate,
  sgst_value,
  igst_rate,
  igst_value,
  CostCenter,
  CostCenterDescription,
  GLAccount,
  AssetNo,
  FixedAssetDescription
