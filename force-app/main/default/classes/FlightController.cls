public with sharing class FlightController {
  @AuraEnabled(cacheable=true)
  public static List<Flight__c> getAvailableFlightsWithKeyword(Id recordId, String searchKeyword) {
    Date preferredDate = tripRepository.getPreferredDateByRecordId(recordId);
    return FlightRepository.getFlightsByDateAndKeyword(preferredDate, searchKeyword);
  }

  @AuraEnabled
  public static void bookFlight(Id tripId, Id flightId) {
    try {
      Ticket__c ticket = FlightRepository.bookFlightForTrip(tripId, flightId);
      TicketController.sendMessageToExternalAPI(ticket.Id);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void cancelBookingFlight(Id tripId) {
    try {
      TripRepository.cancelBookingFlightByTripId(tripId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static FlightDetailsWrapper getFlightDetails(Id tripId) {
    return FlightRepository.getFlightDetailsByTripId(tripId);
  }
}
