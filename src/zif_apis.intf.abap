INTERFACE zif_apis
  PUBLIC .

  CONSTANTS : BEGIN OF c_api_custom_credentials,
                username TYPE string VALUE 'ZAPI_USER',
                password TYPE string VALUE 'fwznqVsTpfraHbjACAVYyoN2onvEt=KMxYmpsoXZ',
              END OF c_api_custom_credentials,

              BEGIN OF c_url,
                supplier_invoice  TYPE string VALUE '/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV',
                outbound_delivery TYPE string VALUE '/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002',
                sales_order       TYPE string VALUE '/sap/opu/odata/sap/API_SALES_ORDER_SRV',
              END OF c_url.


ENDINTERFACE.
