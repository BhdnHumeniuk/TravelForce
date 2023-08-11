public with sharing class TripRepository {
  public static Date getPreferredDateByRecordId(Id recordId) {
    Trip__c trip = [SELECT Preferred_Trip_Start__c FROM Trip__c WHERE Id = :recordId LIMIT 1];
    return trip != null ? trip.Preferred_Trip_Start__c : null;
  }
}
