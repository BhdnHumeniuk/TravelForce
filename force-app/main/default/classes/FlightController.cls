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
      List<Trip__c> trips = TripRepository.getTripsByIds(new Set<Id>{ tripId });
      List<Flight__c> flights = FlightRepository.getFlightsByIds(new Set<Id>{ flightId });

      if (trips.isEmpty() || flights.isEmpty()) {
        throw new AuraHandledException('Invalid trip or flight ID.');
      }

      Trip__c trip = trips[0];
      Flight__c flight = flights[0];

      if (String.isBlank(trip.Flight__c) && trip.Status__c == 'Flight search') {
        List<Ticket__c> availableTickets = TicketRepository.getAvailableTicketsByFlightId(flightId);

        if (!availableTickets.isEmpty()) {
          Ticket__c availableTicket = availableTickets[0];
          availableTicket.Contact__c = trip.Contact__c;
          TicketRepository.updateTickets(new List<Ticket__c>{ availableTicket });

          trip.Flight__c = flightId;
          trip.Status__c = 'Flight booked';
          TripRepository.updateTrips(new List<Trip__c>{ trip });

          Set<Id> ticketIds = new Set<Id>{ availableTicket.Id };
          TicketCalloutService.sendMessageToExternalAPI(ticketIds);
        } else {
          throw new AuraHandledException('No available tickets for the selected flight.');
        }
      } else {
        throw new AuraHandledException('Invalid trip status or flight already booked.');
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static void cancelBookingFlight(Id tripId) {
    try {
      List<Trip__c> tripsToUpdate = new List<Trip__c>();
      List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();

      Trip__c trip = TripRepository.getAndValidateTrip(tripId);
      Flight__c bookedFlight = FlightRepository.getAndValidateBookedFlight(trip.Flight__c);
      List<Ticket__c> bookedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlight.Id, trip.Contact__c);

      if (!bookedTickets.isEmpty()) {
        tripsToUpdate = clearFlightsStatusInTrips(new List<Trip__c>{ trip });
        ticketsToUpdate = clearTicketsBooking(bookedTickets);

        if (!tripsToUpdate.isEmpty()) {
          TripRepository.updateTrips(tripsToUpdate);
        }

        if (!ticketsToUpdate.isEmpty()) {
          TicketRepository.updateTickets(ticketsToUpdate);
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static FlightDetailsWrapper getFlightDetails(Id tripId) {
    return FlightRepository.getFlightDetailsByTripId(tripId);
  }

  public static List<Trip__c> clearFlightsStatusInTrips(List<Trip__c> trips) {
    List<Trip__c> tripsToUpdate = new List<Trip__c>();
    for (Trip__c trip : trips) {
      trip.Flight__c = null;
      trip.Status__c = 'Flight search';
      tripsToUpdate.add(trip);
    }
    return tripsToUpdate;
  }

  public static List<Ticket__c> clearTicketsBooking(List<Ticket__c> tickets) {
    List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();
    for (Ticket__c ticket : tickets) {
      ticket.Contact__c = null;
      ticketsToUpdate.add(ticket);
    }
    return ticketsToUpdate;
  }
}
