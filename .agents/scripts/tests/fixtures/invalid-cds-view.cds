define view entity CustomSalesOrder
  as select from /dmo/travel
  association [0..1] to /dmo/agency as Agency on $projection.AgencyID = Agency.agency_id
{
  key travel_id as TravelID
}
