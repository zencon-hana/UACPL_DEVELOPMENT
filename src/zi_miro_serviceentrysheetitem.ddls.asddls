@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View for service entry sheet item'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity ZI_MIRO_ServiceEntrySheetItem
  as select from I_ServiceEntrySheetItemAPI01
{
  key ServiceEntrySheet,
  key ServiceEntrySheetItem,
      PurchaseOrder,
      PurchaseOrderItem,
      IsDeleted,
      Service,
      ServiceEntrySheetItemDesc,
      ServicePerformer,
      AccountAssignmentCategory,
      MultipleAcctAssgmtDistribution,
      WorkItem,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      ConfirmedQuantity,
      QuantityUnit,
      ServicePerformanceDate,
      OriginObject,
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
      @Semantics.amount.currencyCode: 'Currency'
      NetPriceAmount,
      Currency,
      PurgDocItemExternalReference,
      PurchaseContract,
      PurchaseContractItem,
      PurchasingOrganization,
      PurchasingGroup,
      Plant,
      IsEndOfPurposeBlocked,
      CreationDateTime,
      CreatedByUser,
      LastChangeDateTime,
      LastChangedByUser,
      _ServiceEntrySheet.MaterialDocument,
      _ServiceEntrySheet.MaterialDocumentYear,
      _ServiceEntrySheet.ServiceEntrySheetName,
      /* Associations */
      _ServiceEntrySheet
}
