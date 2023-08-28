public with sharing class TripRepository {
  public static List<Trip__c> getTripsByIds(Set<Id> tripIds) {
    return [SELECT Id, Flight__c, Contact__c, Preferred_Trip_Start__c, Status__c FROM Trip__c WHERE Id IN :tripIds];
  }

  public static Trip__c getAndValidateTrip(Id tripId) {
    Trip__c trip = TripRepository.getTripsByIds(new Set<Id>{ tripId })[0];
    if (trip == null || trip.Status__c != 'Flight booked') {
      throw new AuraHandledException('Invalid trip data for flight rejection.');
    }
    return trip;
  }

  public static void updateTrips(List<Trip__c> trips) {
    try {
      update trips;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating trips: ' + e.getMessage());
    }
  }
}
