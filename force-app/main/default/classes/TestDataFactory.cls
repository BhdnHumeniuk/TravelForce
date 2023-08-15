@IsTest
public with sharing class TestDataFactory {
  public static List<Contact> createContacts(Integer recordCount) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < recordCount; i++) {
      contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact ' + i));
    }
    insert contacts;
    return contacts;
  }

  public static List<Flight__c> createFlights(Integer recordCount) {
    List<Flight__c> flights = new List<Flight__c>();
    for (Integer i = 0; i < recordCount; i++) {
      flights.add(new Flight__c(Name = 'FL' + i, Start__c = DateTime.now().addDays(i)));
    }
    insert flights;
    return flights;
  }

  public static List<Ticket__c> createTickets(Integer recordCount, List<Flight__c> flights) {
    List<Ticket__c> tickets = new List<Ticket__c>();
    Integer flightsCount = flights.size();
    Integer ticketsPerFlight = recordCount / flightsCount;

    for (Integer i = 0; i < flightsCount; i++) {
      Flight__c flight = flights[i];
      for (Integer j = 0; j < ticketsPerFlight; j++) {
        tickets.add(new Ticket__c(Name = 'TKT' + (i * ticketsPerFlight + j), Flight__c = flight.Id));
      }
    }
    insert tickets;
    return tickets;
  }

  public static List<Trip__c> createTrips(Integer recordCount, List<Contact> contacts) {
    List<Trip__c> trips = new List<Trip__c>();
    for (Integer i = 0; i < recordCount; i++) {
      trips.add(new Trip__c(Contact__c = contacts[i].Id, Preferred_Trip_Start__c = Date.today().addDays(i)));
    }
    insert trips;
    return trips;
  }

  public static List<Flight__c> assignContactsToTickets(List<Ticket__c> tickets, List<Contact> contacts) {
    Set<Id> flightIds = new Set<Id>();

    for (Integer i = 0; i < tickets.size(); i++) {
      if (i < contacts.size()) {
        tickets[i].Contact__c = contacts[i].Id;
        flightIds.add(tickets[i].Flight__c);
      }
    }
    update tickets;
    return [SELECT Id FROM Flight__c WHERE Id IN :flightIds];
  }

  public static List<Trip__c> assignFlightsToTrips(List<Flight__c> flights, List<Trip__c> trips) {
    List<Trip__c> tripsToUpdate = new List<Trip__c>();

    for (Integer i = 0; i < trips.size(); i++) {
      if (i < flights.size()) {
        Trip__c trip = trips[i];
        trip.Flight__c = flights[i].Id;
        trip.Status__c = 'Flight booked';
        tripsToUpdate.add(trip);
      }
    }
    update tripsToUpdate;
    return [SELECT Id FROM Trip__c WHERE Id IN :tripsToUpdate];
  }
}
