public with sharing class FlightController {
  @AuraEnabled(cacheable=true)
  public static List<Flight__c> getAvailableFlightsWithKeyword(Id recordId, String searchKeyword) {
    Set<Id> tripIds = new Set<Id>{ recordId };
    List<Trip__c> trips = TripRepository.getTripsByIds(tripIds);
    Date preferredDate = trips[0].Preferred_Trip_Start__c;
    if (preferredDate != null) {
      return FlightRepository.getFlightsByDateAndKeyword(preferredDate, searchKeyword);
    } else {
      throw new AuraHandledException('Trip not found.');
    }
  }

  @AuraEnabled
  public static void bookFlight(Id tripId, Id flightId) {
    try {
      Ticket__c bookedTicket = FlightRepository.bookFlightForTrip(tripId, flightId);

      if (bookedTicket != null) {
        Set<Id> ticketIds = new Set<Id>{ bookedTicket.Id };
        TicketController.sendMessageToExternalAPI(ticketIds);
      }
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
