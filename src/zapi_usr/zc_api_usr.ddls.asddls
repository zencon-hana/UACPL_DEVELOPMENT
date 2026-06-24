@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for API User'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_API_USR
  as select from zapi_usr
{

      @EndUserText.label : 'User'
  key api_user as ApiUser,
      @EndUserText.label : 'system'
  key sysid    as Sysid,
      @EndUserText.label : 'Password'
      password as Password
}
