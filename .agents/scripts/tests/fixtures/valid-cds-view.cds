@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Order Interface View'
@ObjectModel.usageType: {
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #TRANSACTIONAL
}
@Metadata.allowExtensions: true
define view entity ZI_SalesOrder
  as select from /dmo/travel
  association [0..1] to /dmo/agency as _Agency on $projection.AgencyID = _Agency.agency_id
{
  key travel_id as TravelID,
      agency_id as AgencyID,
      customer_id as CustomerID,
      _Agency
}
