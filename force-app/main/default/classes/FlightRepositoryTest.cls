@IsTest
private class FlightRepositoryTest {
  @TestSetup
  static void setupTestData() {
    List<Flight__c> flights = TestDataFactory.createFlights(10);
    List<Contact> contacts = TestDataFactory.createContacts(10);
    List<Trip__c> trips = TestDataFactory.createTrips(10, contacts);
    List<Ticket__c> tickets = TestDataFactory.createTickets(10, flights);
    TestDataFactory.assignFlightsToTrips(flights, trips);
    TestDataFactory.assignContactsToTickets(tickets, contacts);
  }

  @IsTest
  static void testGetFlightsByDateAndKeyword() {
    List<Flight__c> freeFlights = TestDataFactory.createFlights(1);
    List<Ticket__c> freeTickets = TestDataFactory.createTickets(1, freeFlights);
    String keyword = 'FL';
    Date preferredDate = Date.today();

    Test.startTest();
    List<Flight__c> flights = FlightRepository.getFlightsByDateAndKeyword(preferredDate, keyword);
    Test.stopTest();

    System.assertEquals(1, flights.size());
    for (Flight__c flight : flights) {
      System.assertEquals(preferredDate, flight.Start__c.date());
      System.assert(flight.Name.contains(keyword));
    }
  }

  // @IsTest
  // static void testBookFlightForTrip_Success() {
  //   List<Flight__c> freeFlights = TestDataFactory.createFlights(1);
  //   List<Contact> newContacts = TestDataFactory.createContacts(1);
  //   Ticket__c freeTickets = TestDataFactory.createTickets(1, freeFlights)[0];
  //   Trip__c newTrip = TestDataFactory.createTrips(1, newContacts)[0];

  //   Test.startTest();
  //   Ticket__c bookedTicket = FlightRepository.bookFlightForTrip(newTrip.Id, freeFlights[0].Id);
  //   Test.stopTest();

  //   System.assertNotEquals(null, bookedTicket);
  //   System.assertEquals(newTrip.Contact__c, bookedTicket.Contact__c);

  //   Trip__c updatedTrip = [SELECT Id, Flight__c, Status__c FROM Trip__c WHERE Id = :newTrip.Id];
  //   System.assertEquals(freeFlights[0].Id, updatedTrip.Flight__c);
  //   System.assertEquals('Flight booked', updatedTrip.Status__c);
  // }

  // @IsTest
  // static void testBookFlightForTrip_InvalidTrip() {
  //   Trip__c trip = [SELECT Id FROM Trip__c WHERE Status__c != 'Flight search' LIMIT 1];
  //   Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];

  //   Test.startTest();
  //   try {
  //     FlightRepository.bookFlightForTrip(trip.Id, flight.Id);
  //     System.assert(false, 'Exception should have been thrown');
  //   } catch (AuraHandledException e) {
  //     System.assertEquals('Invalid trip or flight data for booking.', e.getMessage());
  //   }
  //   Test.stopTest();
  // }

  // @IsTest
  // static void testBookFlightForTrip_NoAvailableTickets() {
  //   Trip__c trip = [SELECT Id, Contact__c, Status__c FROM Trip__c WHERE Status__c = 'Flight search' LIMIT 1];
  //   Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];

  //   List<Ticket__c> tickets = [SELECT Id FROM Ticket__c WHERE Flight__c = :flight.Id];
  //   for (Ticket__c ticket : tickets) {
  //     ticket.Contact__c = trip.Contact__c;
  //   }
  //   update tickets;

  //   Test.startTest();
  //   try {
  //     FlightRepository.bookFlightForTrip(trip.Id, flight.Id);
  //     System.assert(false, 'Exception should have been thrown');
  //   } catch (AuraHandledException e) {
  //     System.assertEquals('No available tickets for booking.', e.getMessage());
  //   }
  //   Test.stopTest();
  // }

  @IsTest
  static void testGetFlightDetailsByTripId() {
    Trip__c trip = [SELECT Id, Flight__c, Contact__c FROM Trip__c LIMIT 1];
    Flight__c flight = [SELECT Id, Flight_Number__c, Start__c FROM Flight__c WHERE Id = :trip.Flight__c LIMIT 1];
    Ticket__c ticket = [SELECT Id, Name, Ticket_Number__c FROM Ticket__c WHERE Flight__c = :flight.Id AND Contact__c = :trip.Contact__c LIMIT 1];

    Test.startTest();
    FlightDetailsWrapper result = FlightRepository.getFlightDetailsByTripId(trip.Id);
    Test.stopTest();

    System.assertEquals(flight.Flight_Number__c, result.flightNumber);
    System.assertEquals(String.valueOf(flight.Start__c), result.flightStart);
    System.assertEquals(ticket.Name, result.ticketName);
    System.assertEquals(ticket.Ticket_Number__c, result.ticketNumber);
  }
}