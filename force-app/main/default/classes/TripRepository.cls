public with sharing class TripRepository {
  public static Trip__c getTripById(Id tripId) {
    return [SELECT Id, Flight__c, Contact__c, Preferred_Trip_Start__c, Status__c FROM Trip__c WHERE Id = :tripId];
  }

  public static void cancelBookingFlightByTripId(Id tripId) {
    Trip__c trip = getTripById(tripId);

    if (trip != null && trip.Status__c == 'Flight booked') {
      Flight__c bookedFlight = FlightRepository.getFlightById(trip.Flight__c);

      if (bookedFlight != null) {
        trip.Flight__c = null;
        trip.Status__c = 'Flight search';
        updateTrip(trip);

        List<Ticket__c> bookedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlight.Id, trip.Contact__c);
        if (!bookedTickets.isEmpty()) {
          bookedTickets[0].Contact__c = null;
          TicketRepository.updateTicket(bookedTickets[0]);
        }
      } else {
        throw new AuraHandledException('Invalid booked flight data.');
      }
    } else {
      throw new AuraHandledException('Invalid trip data for flight rejection.');
    }
  }

  public static void updateTrip(Trip__c trip) {
    try {
      update trip;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating trips: ' + e.getMessage());
    }
  }
}
