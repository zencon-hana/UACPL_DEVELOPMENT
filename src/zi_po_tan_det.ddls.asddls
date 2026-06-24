@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO TAN det'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
define view entity zi_po_tan_det
  as select from I_PurchaseOrderItemAPI01

{
      //      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' } }]
  key PurchaseOrder,
  key PurchaseOrderItem,
      PurchaseOrderItemCategory,
      CompanyCode,
      _PurchaseOrder.Supplier,
      _PurchaseOrder._Supplier.BusinessPartnerPanNumber,
      DocumentCurrency,
      AccountAssignmentCategory,
      case when ( cast( cast( substring($session.system_date, 5, 2) as abap.numc( 2 ) ) as abap.int1 ) < 4 )
           then cast( concat( cast( cast( cast( substring($session.system_date, 1, 4) as abap.numc( 4 ) ) as abap.int2 ) - 1 as abap.char( 12 ) ) , '0401') as abap.dats )
           else cast( concat( substring($session.system_date, 1, 4) , '0401') as abap.dats ) end as TANExemptDate

      //      POItem._PurchaseOrder,
      //      POItem._PurchaseOrder._Supplier
}

union all

select from       I_SchedgAgrmtItmApi01 //I_SchedgAgrmtItm

  left outer join I_SchedgagrmthdrApi01 as _SchedgAgrmtHdrAPI01 on I_SchedgAgrmtItmApi01.SchedulingAgreement = _SchedgAgrmtHdrAPI01.SchedulingAgreement

association [0..1] to I_Supplier as _supplier on _supplier.Supplier = _SchedgAgrmtHdrAPI01.Supplier

{

  key I_SchedgAgrmtItmApi01.SchedulingAgreement                                                             as PurchaseOrder,
  key I_SchedgAgrmtItmApi01.SchedulingAgreementItem                                                         as PurchaseOrderItem,
      coalesce( I_SchedgAgrmtItmApi01.YY1_PSTYP2_PDI, '0')                                                  as PurchaseOrderItemCategory,
      I_SchedgAgrmtItmApi01.CompanyCode,
      _SchedgAgrmtHdrAPI01.Supplier,
      _supplier.BusinessPartnerPanNumber,
      I_SchedgAgrmtItmApi01.DocumentCurrency,
      I_SchedgAgrmtItmApi01.AccountAssignmentCategory,
      case when ( cast( cast( substring($session.system_date, 5, 2) as abap.numc( 2 ) ) as abap.int1 ) < 4 )
                      then cast( concat( cast( cast( cast( substring($session.system_date, 1, 4) as abap.numc( 4 ) ) as abap.int2 ) - 1 as abap.char( 12 ) ) , '0401') as abap.dats )
                      else cast( concat( substring($session.system_date, 1, 4) , '0401') as abap.dats ) end as TANExemptDate
}
