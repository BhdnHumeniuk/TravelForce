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

  public static List<Flight__c> getFlightsByIds(Set<Id> flightIds) {
    return [SELECT Id, Name, Start__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIds];
  }

  public static Flight__c getFlightById(Id flightId) {
    return [SELECT Id, Name, Start__c, Flight_Number__c FROM Flight__c WHERE Id = :flightId LIMIT 1];
  }

  public static FlightDetailsWrapper getFlightDetailsByTripId(Id tripId) {
    FlightDetailsWrapper result = new FlightDetailsWrapper();

    Trip__c trip = [SELECT Id, Flight__c, Status__c, Contact__c FROM Trip__c WHERE Id = :tripId];
    if (trip != null) {
      if (trip.Flight__c != null) {
        Flight__c flight = [SELECT Id, Name, Flight_Number__c, Start__c FROM Flight__c WHERE Id = :trip.Flight__c];
        if (flight != null) {
          result.flightId = flight.Id;
          result.flightNumber = flight.Flight_Number__c;
          result.flightStart = String.valueOf(flight.Start__c);
        }
      }

      if (trip.Contact__c != null) {
        List<Ticket__c> tickets = [SELECT Id, Name, Ticket_Number__c FROM Ticket__c WHERE Flight__c = :trip.Flight__c AND Contact__c = :trip.Contact__c];
        if (!tickets.isEmpty()) {
          Ticket__c ticket = tickets[0];
          result.ticketId = ticket.Id;
          result.ticketName = ticket.Name;
          result.ticketNumber = ticket.Ticket_Number__c;
        }
      }
    }

    return result;
  }

  // public static Flight__c getAndValidateBookedFlight(Id flightId) {
  //   Flight__c bookedFlight = FlightRepository.getFlightsByIds(new Set<Id>{ flightId })[0];
  //   if (bookedFlight == null) {
  //     throw new AuraHandledException('Invalid booked flight data.');
  //   }
  //   return bookedFlight;
  // }
}
