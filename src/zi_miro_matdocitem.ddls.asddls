@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material document item for MIRO app'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MIRO_MatDocItem
  as select from    I_MaterialDocumentItem_2 as _MatDoc
    left outer join I_MaterialDocumentItem_2 as _RevMatDoc  on  _RevMatDoc.ReversedMaterialDocumentYear = _MatDoc.MaterialDocumentYear
                                                            and _RevMatDoc.ReversedMaterialDocument     = _MatDoc.MaterialDocument
                                                            and _RevMatDoc.ReversedMaterialDocumentItem = _MatDoc.MaterialDocumentItem
                                                            and _RevMatDoc.GoodsMovementType            = '102'

    left outer join I_MaterialDocumentItem_2 as _MatDoc_122 on  _MatDoc_122.ReferenceDocumentFiscalYear = _MatDoc.MaterialDocumentYear
                                                            and _MatDoc_122.InvtryMgmtReferenceDocument = _MatDoc.MaterialDocument
                                                            and _MatDoc_122.InvtryMgmtRefDocumentItem   = _MatDoc.MaterialDocumentItem
                                                            and _MatDoc_122.GoodsMovementType           = '122'

{
  key _MatDoc.MaterialDocumentYear,
      @Search: {
                    defaultSearchElement: true,
                    fuzzinessThreshold: 0.9,
                    ranking: #HIGH
               }
  key _MatDoc.MaterialDocument,
  key _MatDoc.MaterialDocumentItem,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      @Aggregation.default: #SUM
      cast( ( _MatDoc.QuantityInDeliveryQtyUnit - sum( coalesce( _MatDoc_122.QuantityInDeliveryQtyUnit, cast( 0 as abap.quan( 13, 3 ) ) ) ) ) as abap.quan( 13, 3 ) )     as QuantityInDeliveryQtyUnit,
      _MatDoc.DeliveryQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      @DefaultAggregation: #SUM
      cast( ( _MatDoc.QuantityInEntryUnit - sum( coalesce( _MatDoc_122.QuantityInEntryUnit, cast( 0 as abap.quan( 13, 3 ) ) ) ) ) as abap.quan( 13, 3 ) )                 as QuantityInEntryUnit, //erfmg
      _MatDoc.EntryUnit,
      _MatDoc.OrderPriceUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      @Aggregation.default: #SUM
      cast( ( _MatDoc.QtyInPurchaseOrderPriceUnit - sum( coalesce( _MatDoc_122.QtyInPurchaseOrderPriceUnit, cast( 0 as abap.quan( 13, 3 ) ) ) ) ) as abap.quan( 13, 3 ) ) as QtyInPurchaseOrderPriceUnit,
      _MatDoc._MaterialDocumentHeader.ReferenceDocument,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      sum( coalesce( _MatDoc_122.QuantityInDeliveryQtyUnit, cast( 0 as abap.quan( 13, 3 ) ) ) )                                                                           as QuantityInDelQtyUnit_122,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      sum( coalesce( _MatDoc_122.QuantityInEntryUnit, cast( 0 as abap.quan( 13, 3 ) ) ) )                                                                                 as QuantityInEntryUnit_122,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      sum( coalesce( _MatDoc_122.QtyInPurchaseOrderPriceUnit, cast( 0 as abap.quan( 13, 3 ) ) ) )                                                                         as QtyInPOPriceUnit_122,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      @Aggregation.default: #SUM
      _MatDoc.QuantityInDeliveryQtyUnit                                                                                                                                   as QuantityInDeliveryQtyUnit_101,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _MatDoc.QuantityInEntryUnit                                                                                                                                         as QuantityInEntryUnit_101,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      _MatDoc.QtyInPurchaseOrderPriceUnit                                                                                                                                 as QtyInPOPriceUnit_101,
      _MatDoc.CostCenter,
      _MatDoc.GLAccount


}
where
  _RevMatDoc.MaterialDocument is null //Don't consider reversed/cancelled documents
group by
  _MatDoc.MaterialDocumentYear,
  _MatDoc.MaterialDocument,
  _MatDoc.MaterialDocumentItem,
  _MatDoc.QuantityInDeliveryQtyUnit,
  _MatDoc.DeliveryQuantityUnit,
  _MatDoc.QuantityInEntryUnit, //erfmg
  _MatDoc.EntryUnit,
  _MatDoc.OrderPriceUnit,
  _MatDoc.QtyInPurchaseOrderPriceUnit,
  _MatDoc._MaterialDocumentHeader.ReferenceDocument,
  _MatDoc.CostCenter,
  _MatDoc.GLAccount
