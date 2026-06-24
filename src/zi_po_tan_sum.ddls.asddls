@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO TAN amount sum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_po_tan_sum
  as select from zi_po_tan
{
  key PurchaseOrder,
  key PurchaseOrderItem,
      PurchaseOrderItemCategory,
      CompanyCode,
      Supplier,
      BusinessPartnerPanNumber,
      TANExemptDate,
      CompanyCodeCurrency,
      TANAccumWithholdingTaxCode,
      TANAccumWithholdingTaxType,
      TANExempWithholdingTaxType,
      TANExempWithholdingTaxCode,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( IN_AccumulationAmount ) as IN_AccumulationAmount,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( IN_ThresholdAmount )    as IN_ThresholdAmount
}
group by
  PurchaseOrder,
  PurchaseOrderItem,
  PurchaseOrderItemCategory,
  CompanyCode,
  Supplier,
  BusinessPartnerPanNumber,
  TANExemptDate,
  CompanyCodeCurrency,
  TANAccumWithholdingTaxCode,
  TANAccumWithholdingTaxType,
  TANExempWithholdingTaxType,
  TANExempWithholdingTaxCode
