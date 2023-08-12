public with sharing class TripRepository {
  public static Date getPreferredDateByRecordId(Id recordId) {
    Trip__c trip = [SELECT Preferred_Trip_Start__c FROM Trip__c WHERE Id = :recordId LIMIT 1];
    return trip != null ? trip.Preferred_Trip_Start__c : null;
  }

  public static void cancelBookingFlightByTripId(Id tripId) {
    Trip__c trip = [SELECT Id, Flight__c, Status__c, Contact__c FROM Trip__c WHERE Id = :tripId];

    if (trip != null && trip.Status__c == 'Flight booked') {
      Flight__c bookedFlight = [SELECT Id FROM Flight__c WHERE Id = :trip.Flight__c];

      if (bookedFlight != null) {
        trip.Flight__c = null;
        trip.Status__c = 'Flight search';
        update trip;

        List<Ticket__c> bookedTickets = [SELECT Id, Contact__c FROM Ticket__c WHERE Flight__c = :bookedFlight.Id AND Contact__c = :trip.Contact__c LIMIT 1]; //Refactor
        if (!bookedTickets.isEmpty()) {
          bookedTickets[0].Contact__c = null;
          update bookedTickets[0];
        }
      } else {
        throw new AuraHandledException('Invalid booked flight data.');
      }
    } else {
      throw new AuraHandledException('Invalid trip data for flight rejection.');
    }
  }
}
