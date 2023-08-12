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

  public static Ticket__c bookFlightForTrip(Id tripId, Id flightId) {
    Trip__c trip = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c WHERE Id = :tripId];
    Flight__c flight = [SELECT Id, Name, Flight_Number__c FROM Flight__c WHERE Id = :flightId];

    if (trip != null && flight != null && String.isBlank(trip.Flight__c) && trip.Status__c == 'Flight search') {
      List<Ticket__c> availableTickets = [SELECT Id, Name, Contact__c, Contact__r.Name FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = NULL LIMIT 1];

      if (!availableTickets.isEmpty()) {
        Ticket__c ticket = availableTickets[0];
        ticket.Contact__c = trip.Contact__c;
        update ticket;

        trip.Flight__c = flightId;
        trip.Status__c = 'Flight booked';
        update trip;

        return ticket;
      } else {
        throw new AuraHandledException('No available tickets for booking.');
      }
    } else {
      throw new AuraHandledException('Invalid trip or flight data for booking.');
    }
  }
}
