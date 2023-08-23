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
        TicketCalloutService.sendMessageToExternalAPI(ticketIds);
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void cancelBookingFlight(Id tripId) {
    try {
      Trip__c trip = TripRepository.getAndValidateTrip(tripId);
      Flight__c bookedFlight = FlightRepository.getAndValidateBookedFlight(trip.Flight__c);

      List<Trip__c> tripsToUpdate = new List<Trip__c>();
      List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();

      TripRepository.cancelTripBooking(trip, tripsToUpdate, bookedFlight, ticketsToUpdate);

      if (!tripsToUpdate.isEmpty()) {
        TripRepository.updateTrips(tripsToUpdate);
      }

      if (!ticketsToUpdate.isEmpty()) {
        TicketRepository.updateTickets(ticketsToUpdate);
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static FlightDetailsWrapper getFlightDetails(Id tripId) {
    return FlightRepository.getFlightDetailsByTripId(tripId);
  }

  @future(callout=true)
  private static void sendMessage(String reply) {
    TelegramUtility.Message message = new TelegramUtility.Message('275517799', reply);
    TelegramUtility.sendMessage(message);
  }
}
