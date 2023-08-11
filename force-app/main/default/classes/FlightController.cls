public with sharing class FlightController {
  @AuraEnabled(cacheable=true)
  public static List<Flight__c> getAvailableFlightsWithKeyword(Id recordId, String searchKeyword) {
    Date preferredDate = tripRepository.getPreferredDateByRecordId(recordId);
    return FlightRepository.getFlightsByDateAndKeyword(preferredDate, searchKeyword);
  }

  @AuraEnabled
  public static void bookFlight(Id tripId, Id flightId) {
    FlightRepository.bookFlightForTrip(tripId, flightId);
  }
}
