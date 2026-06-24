@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Int. view for PO TAN amount calc'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity zi_po_tan
  as select from ZI_PO_TAN_DET2 as POItem

  //    inner join zi_tanexempt_date        as _ExempDate on _ExempDate.PurchasingDocumentItemCategory = POItem.PurchaseOrderItemCategory

  association [0..*] to I_IN_TANAccumulationDetail as _TANAccumulation on  _TANAccumulation.CompanyCode              = $projection.CompanyCode
                                                                       and _TANAccumulation.CustomerSupplierAccount  = $projection.Supplier
                                                                       and _TANAccumulation.WithholdingTaxType       = $projection.WithholdingTaxType
                                                                       and _TANAccumulation.WithholdingTaxCode       = $projection.WithholdingTaxCode
                                                                       and _TANAccumulation.TaxSection               = '1100'
                                                                         and _TANAccumulation.ExemptionDateBegin       = $projection.TANExemptDate
                                                                       and _TANAccumulation.FinancialAccountType     = 'K'
                                                                       and _TANAccumulation.BusinessPartnerPanNumber = $projection.BusinessPartnerPanNumber

  association [0..*] to I_IN_TANExemptionDetail    as _TANExemption    on  _TANExemption.CompanyCode              = $projection.CompanyCode
                                                                       and _TANExemption.FinancialAccountType     = 'K'
                                                                       and _TANExemption.CustomerSupplierAccount  = $projection.Supplier
                                                                       and _TANExemption.TaxSection               = '1100'
                                                                       and _TANExemption.WithholdingTaxType       = $projection.WithholdingTaxType
                                                                       and _TANExemption.WithholdingTaxCode       = $projection.WithholdingTaxCode
                                                                       and _TANExemption.BusinessPartnerPanNumber = $projection.BusinessPartnerPanNumber
                                                                       and _TANExemption.ExemptionDateBegin      >= POItem.TANExemptDate 
//                                                                       and _TANExemption.ExemptionDateBegin       < $session.system_date
//                                                                       and _TANExemption.ExemptionDateEnd         > $session.system_date 


{
  key POItem.PurchaseOrder,
  key POItem.PurchaseOrderItem,
      POItem.PurchaseOrderItemCategory,
      POItem.CompanyCode,
      POItem.Supplier,
      POItem.BusinessPartnerPanNumber,
      POItem.TANExemptDate,
      WithholdingTaxCode,
      WithholdingTaxType,
      _TANAccumulation.WithholdingTaxCode                                         as TANAccumWithholdingTaxCode,
      _TANAccumulation.WithholdingTaxType                                         as TANAccumWithholdingTaxType,
      _TANExemption.WithholdingTaxType                                            as TANExempWithholdingTaxType,
      _TANExemption.WithholdingTaxCode                                            as TANExempWithholdingTaxCode,
      POItem.DocumentCurrency                                                     as CompanyCodeCurrency,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast( sum( _TANAccumulation.IN_AccumulationAmount ) as abap.dec( 23, 2 ) ) as IN_AccumulationAmount,
      //      sum(
      //      case when POItem.PurchaseOrderItemCategory = '0' and _TANAccumulation.WithholdingTaxCode = '4Q'
      //       then _TANAccumulation.IN_AccumulationAmount
      //           when POItem.PurchaseOrderItemCategory <> '0' and _TANAccumulation.WithholdingTaxCode <> '4Q'
      //       then _TANAccumulation.IN_AccumulationAmount
      //       else cast( 0 as abap.curr( 23, 2 ) )
      //       end )                              as IN_AccumulationAmount,

//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//            sum(
      //      case when POItem.PurchaseOrderItemCategory = '0' and _TANExemption.WithholdingTaxCode = '4Q'
      //      then _TANExemption.IN_ThresholdAmount
      //          when POItem.PurchaseOrderItemCategory <> '0' and _TANExemption.WithholdingTaxCode <> '4Q'
      //      then _TANExemption.IN_ThresholdAmount
      //      else cast( 0 as abap.curr( 23, 2 ) )
      //      end )                               as IN_ThresholdAmount
      cast( sum( _TANExemption.IN_ThresholdAmount ) as abap.dec( 23, 2 ) )       as IN_ThresholdAmount
}
group by
  POItem.PurchaseOrder,
  POItem.PurchaseOrderItem,
  POItem.PurchaseOrderItemCategory,
  POItem.CompanyCode,
  POItem.Supplier,
  POItem.BusinessPartnerPanNumber,
  POItem.TANExemptDate,
  POItem.DocumentCurrency,
  WithholdingTaxCode,
  WithholdingTaxType,
  _TANAccumulation.WithholdingTaxCode,
  _TANAccumulation.WithholdingTaxType,
  _TANExemption.WithholdingTaxType,
  _TANExemption.WithholdingTaxCode
