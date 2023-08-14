public with sharing class TripRepository {
  public static List<Trip__c> getTripsByIds(Set<Id> tripIds) {
    return [SELECT Id, Flight__c, Contact__c, Preferred_Trip_Start__c, Status__c FROM Trip__c WHERE Id IN :tripIds];
  }

  public static void cancelBookingFlightByTripId(Id tripId) {
    try {
      Set<Id> tripIds = new Set<Id>{ tripId };
      List<Trip__c> trips = TripRepository.getTripsByIds(tripIds);

      List<Trip__c> tripsToUpdate = new List<Trip__c>();
      List<Ticket__c> ticketsToUpdate = new List<Ticket__c>();

      for (Trip__c trip : trips) {
        if (trip != null && trip.Status__c == 'Flight booked') {
          Set<Id> flightIds = new Set<Id>{ trip.Flight__c };
          List<Flight__c> bookedFlights = FlightRepository.getFlightsByIds(flightIds);

          for (Flight__c bookedFlight : bookedFlights) {
            if (bookedFlight != null) {
              trip.Flight__c = null;
              trip.Status__c = 'Flight search';
              tripsToUpdate.add(trip);

              List<Ticket__c> bookedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlight.Id, trip.Contact__c);
              if (!bookedTickets.isEmpty()) {
                for (Ticket__c ticket : bookedTickets) {
                  ticket.Contact__c = null;
                  ticketsToUpdate.add(ticket);
                }
              }
            } else {
              throw new AuraHandledException('Invalid booked flight data.');
            }
          }
        } else {
          throw new AuraHandledException('Invalid trip data for flight rejection.');
        }
      }

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

  public static void updateTrips(List<Trip__c> trips) {
    try {
      update trips;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating trips: ' + e.getMessage());
    }
  }
}
