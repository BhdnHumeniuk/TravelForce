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

  @AuraEnabled(cacheable=true)
  public static FlightDetailsWrapper getFlightDetails(Id tripId) {
    return FlightRepository.getFlightDetailsByTripId(tripId);
  }

  public static void bookFlight(List<Trip__c> trips) {
    List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();
    Set<Id> ticketIds = new Set<Id>();
    try {
      for (Trip__c trip : trips) {
        Flight__c flight = FlightRepository.getFlightById(trip.Flight__c);

        List<Ticket__c> availableTickets = TicketRepository.getTicketsByFlightId(flight.Id);

        if (!availableTickets.isEmpty()) {
          Ticket__c availableTicket = availableTickets[0];
          availableTicket.Contact__c = trip.Contact__c;

          ticketsToUpdate.add(availableTicket);
          ticketIds.add(availableTicket.Id);
        } else {
          throw new AuraHandledException('No available tickets for the selected flight.');
        }
      }

      if (!ticketsToUpdate.isEmpty()) {
        TicketRepository.updateTickets(ticketsToUpdate);
        TicketCalloutService.sendMessageToExternalAPI(ticketIds);
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  public static void cancelBookingFlight(List<Trip__c> trips) {
    List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();
    try {
      for (Trip__c trip : trips) {
        Flight__c bookedFlight = FlightRepository.getFlightById(trip.Flight__c);
        try {
          Ticket__c bookedTicket = TicketRepository.getTicketByFlightIdAndContactId(bookedFlight.Id, trip.Contact__c);
          bookedTicket.Contact__c = null;
          ticketsToUpdate.add(bookedTicket);
        } catch (QueryException e) {
          System.debug('No available booked tickets for trip with ID: ' + trip.Id);
        }
      }
      if (!ticketsToUpdate.isEmpty()) {
        TicketRepository.updateTickets(ticketsToUpdate);
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }
}
