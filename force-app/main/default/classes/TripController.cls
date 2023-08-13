public with sharing class TripController {
  @AuraEnabled(cacheable=true)
  public static Boolean isTripBookedFlight(Id tripId) {
    String tripStatus = TripRepository.getTripById(tripId).Status__c;
    if (tripStatus != null) {
      if (tripStatus == 'Flight booked') {
        return true;
      } else if (tripStatus == 'Flight search') {
        return false;
      } else {
        throw new AuraHandledException('Invalid trip status.');
      }
    } else {
      throw new AuraHandledException('Trip not found.');
    }
  }
}
