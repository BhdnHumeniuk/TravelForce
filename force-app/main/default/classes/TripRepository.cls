public with sharing class TripRepository {
  public static List<Trip__c> getTripsByIds(Set<Id> tripIds) {
    return [SELECT Id, Flight__c, Contact__c, Preferred_Trip_Start__c, Status__c FROM Trip__c WHERE Id IN :tripIds];
  }

  public static void updateTrips(List<Trip__c> trips) {
    try {
      update trips;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating trips: ' + e.getMessage());
    }
  }
}
