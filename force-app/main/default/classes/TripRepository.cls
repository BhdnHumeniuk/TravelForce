public with sharing class TripRepository {
  public static List<Trip__c> getTripsByIds(Set<Id> tripIds) {
    return [SELECT Id, Flight__c, Contact__c, Preferred_Trip_Start__c, Status__c FROM Trip__c WHERE Id IN :tripIds];
  }

  public static Trip__c getAndValidateTrip(Id tripId) {
    Trip__c trip = TripRepository.getTripsByIds(new Set<Id>{ tripId })[0];
    if (trip == null || trip.Status__c != 'Flight booked') {
      throw new AuraHandledException('Invalid trip data for flight rejection.');
    }
    return trip;
  }

  public static void cancelTripBooking(Trip__c trip, List<Trip__c> tripsToUpdate, Flight__c bookedFlight, List<Ticket__c> ticketsToUpdate) {
    trip.Flight__c = null;
    trip.Status__c = 'Flight search';
    tripsToUpdate.add(trip);

    List<Ticket__c> bookedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlight.Id, trip.Contact__c);
    for (Ticket__c ticket : bookedTickets) {
      ticket.Contact__c = null;
      ticketsToUpdate.add(ticket);
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
