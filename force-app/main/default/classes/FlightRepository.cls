public with sharing class FlightRepository {
  public static List<Flight__c> getFlightsByDateAndKeyword(Date preferredDate, String keyword) {
    DateTime startOfDay = DateTime.newInstance(preferredDate, Time.newInstance(0, 0, 0, 0));
    DateTime endOfDay = DateTime.newInstance(preferredDate, Time.newInstance(23, 59, 59, 999));

    return [
      SELECT Id, Name, Flight_Number__c, Start__c
      FROM Flight__c
      WHERE Start__c >= :startOfDay AND Start__c <= :endOfDay AND Id IN (SELECT Flight__c FROM Ticket__c WHERE Contact__c = NULL) AND Name LIKE :('%' + keyword + '%')
    ];
  }

  public static List<Flight__c> getFlightsByIds(Set<Id> flightId) {
    return [SELECT Id, Name, Start__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightId];
  }

  public static Ticket__c bookFlightForTrip(Id tripId, Id flightId) {
    Set<Id> tripIds = new Set<Id>{ tripId };
    Set<Id> flights = new Set<Id>{ flightId };
    Trip__c trip = TripRepository.getTripsByIds(tripIds)[0];
    Flight__c flight = getFlightsByIds(flights)[0];

    if (trip != null && flight != null && String.isBlank(trip.Flight__c) && trip.Status__c == 'Flight search') {
      Ticket__c availableTicket = TicketRepository.getAvailableTicketsByFlightId(flightId)[0];

      if (availableTicket != null) {
        availableTicket.Contact__c = trip.Contact__c;
        TicketRepository.updateTickets(new List<Ticket__c>{ availableTicket });

        trip.Flight__c = flightId;
        trip.Status__c = 'Flight booked';
        TripRepository.updateTrips(new List<Trip__c>{ trip });

        return availableTicket;
      } else {
        throw new AuraHandledException('No available tickets for booking.');
      }
    } else {
      throw new AuraHandledException('Invalid trip or flight data for booking.');
    }
  }

  public static FlightDetailsWrapper getFlightDetailsByTripId(Id tripId) {
    FlightDetailsWrapper result = new FlightDetailsWrapper();
    try {
      Set<Id> tripIds = new Set<Id>{ tripId };
      Trip__c trip = TripRepository.getTripsByIds(tripIds)[0];
      if (trip != null) {
        if (trip.Flight__c != null) {
          Set<Id> flightIds = new Set<Id>{ trip.Flight__c };
          Flight__c flight = getFlightsByIds(flightIds)[0];
          if (flight != null) {
            result.flightNumber = flight.Flight_Number__c;
            result.flightStart = String.valueOf(flight.Start__c);
          } else {
            throw new AuraHandledException('Flight not found.');
          }
        }
        if (trip.Contact__c != null) {
          Ticket__c ticket = TicketRepository.getTicketsByFlightIdAndContactId(trip.Flight__c, trip.Contact__c)[0];
          if (ticket != null) {
            result.ticketName = ticket.Name;
            result.ticketNumber = ticket.Ticket_Number__c;
          } else {
            throw new AuraHandledException('Ticket not found.');
          }
        }
      } else {
        throw new AuraHandledException('Trip not found.');
      }
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }

    return result;
  }
}
