@IsTest
private class FlightControllerTest {
  @TestSetup
  static void setupTestData() {
    List<Contact> contacts = TestDataFactory.createContacts(1);
    List<Flight__c> flights = TestDataFactory.createFlights(1);
    List<Trip__c> trips = TestDataFactory.createTrips(1, contacts);
    List<Ticket__c> tickets = TestDataFactory.createTickets(10, flights);
    TestDataFactory.assignFlightsToTrips(flights, trips);
    TestDataFactory.assignContactsToTickets(tickets, contacts);
  }

  @IsTest
  static void testGetAvailableFlightsWithKeyword() {
    List<Flight__c> freeFlights = TestDataFactory.createFlights(1);
    List<Ticket__c> freeTickets = TestDataFactory.createTickets(1, freeFlights);
    String keyword = 'FL';
    Date preferredDate = Date.today();
    Trip__c trip = [SELECT Id FROM Trip__c LIMIT 1];

    Test.startTest();
    List<Flight__c> availableFlights = FlightController.getAvailableFlightsWithKeyword(trip.Id, keyword);
    Test.stopTest();

    System.assertNotEquals(0, availableFlights.size());
    for (Flight__c flight : availableFlights) {
      System.assert(flight.Name.contains(keyword));
      System.assertEquals(preferredDate, flight.Start__c.date());
    }
  }

  @IsTest
  static void testBookFlight_Success() {
    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());
    List<Flight__c> freeFlights = TestDataFactory.createFlights(1);
    List<Contact> newContacts = TestDataFactory.createContacts(1);
    Ticket__c freeTickets = TestDataFactory.createTickets(1, freeFlights)[0];
    Trip__c newTrip = TestDataFactory.createTrips(1, newContacts)[0];

    Test.startTest();
    FlightController.bookFlight(newTrip.Id, freeFlights[0].Id);
    Test.stopTest();

    Trip__c updatedTrip = [SELECT Id, Flight__c, Status__c FROM Trip__c WHERE Id = :newTrip.Id];
    System.assertEquals(freeFlights[0].Id, updatedTrip.Flight__c);
    System.assertEquals('Flight booked', updatedTrip.Status__c);
  }

  @IsTest
  static void testCancelBookingFlight() {
    Trip__c trip = [SELECT Id FROM Trip__c LIMIT 1];
    trip.Flight__c = TestDataFactory.createFlights(1)[0].Id;
    trip.Status__c = 'Flight booked';
    update trip;

    Test.startTest();
    FlightController.cancelBookingFlight(trip.Id);
    Test.stopTest();

    Trip__c updatedTrip = [SELECT Id, Flight__c, Status__c FROM Trip__c WHERE Id = :trip.Id];
    System.assertEquals(null, updatedTrip.Flight__c);
    System.assertEquals('Flight search', updatedTrip.Status__c);
  }

  @IsTest
  static void testGetFlightDetails() {
    Trip__c trip = [SELECT Id, Flight__c, Contact__c FROM Trip__c LIMIT 1];
    Flight__c flight = [SELECT Id, Flight_Number__c, Start__c FROM Flight__c WHERE Id = :trip.Flight__c LIMIT 1];
    Ticket__c ticket = [SELECT Id, Name, Ticket_Number__c FROM Ticket__c WHERE Flight__c = :flight.Id AND Contact__c = :trip.Contact__c LIMIT 1];

    Test.startTest();
    FlightDetailsWrapper result = FlightController.getFlightDetails(trip.Id);
    Test.stopTest();

    System.assertEquals(flight.Flight_Number__c, result.flightNumber);
    System.assertEquals(String.valueOf(flight.Start__c), result.flightStart);
    System.assertEquals(ticket.Name, result.ticketName);
    System.assertEquals(ticket.Ticket_Number__c, result.ticketNumber);
  }
}
