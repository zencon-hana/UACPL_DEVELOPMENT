@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO TAN det'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_PO_TAN_DET2
  as select from zi_po_tan_det 
  
  association [0..1] to I_SupplierWithHoldingTax     as _SupplierWithHoldingTax     on  _SupplierWithHoldingTax.Supplier           = $projection.Supplier
                                                                                  and _SupplierWithHoldingTax.CompanyCode        = $projection.CompanyCode
                                                                                  and _SupplierWithHoldingTax.WithholdingTaxType <> '4Q'

 association [0..1] to I_SupplierWithHoldingTax     as _SupplierWithHoldingTax1     on  _SupplierWithHoldingTax1.Supplier           = $projection.Supplier
                                                                                  and _SupplierWithHoldingTax1.CompanyCode        = $projection.CompanyCode
                                                                                  and _SupplierWithHoldingTax1.WithholdingTaxType = '4Q'                                                                                  
{
key PurchaseOrder,
key PurchaseOrderItem,
PurchaseOrderItemCategory,
CompanyCode,
Supplier,
BusinessPartnerPanNumber,
DocumentCurrency,
case when AccountAssignmentCategory <> 'K' and PurchaseOrderItemCategory = '0'
     then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
      when PurchaseOrderItemCategory = ' ' or PurchaseOrderItemCategory = ''
      then coalesce( _SupplierWithHoldingTax1.WithholdingTaxCode, '' )
      else
      coalesce( _SupplierWithHoldingTax.WithholdingTaxCode, '4Q' ) end                                                                                   as WithholdingTaxCode,
                                                                             
 case when AccountAssignmentCategory <> 'K' and PurchaseOrderItemCategory = '0'
            then '4Q'
            when PurchaseOrderItemCategory = ' ' or PurchaseOrderItemCategory = ''
            then '4Q'
            else coalesce( _SupplierWithHoldingTax.WithholdingTaxType, '' ) end                                                as WithholdingTaxType,
TANExemptDate
}
