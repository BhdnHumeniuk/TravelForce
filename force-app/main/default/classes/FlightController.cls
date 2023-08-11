public with sharing class FlightController {
  @AuraEnabled(cacheable=true)
  public static List<Flight__c> getAvailableFlightsWithKeyword(Id recordId, String keyword) {
    Date preferredDate = tripRepository.getPreferredDateByRecordId(recordId);
    return FlightRepository.getFlightsByDateAndKeyword(preferredDate, keyword);
  }
}
