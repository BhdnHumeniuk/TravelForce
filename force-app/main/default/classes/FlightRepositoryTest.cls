@IsTest
private class FlightRepositoryTest {
  //   @TestSetup
  //   static void setupTestData() {
  //     TestDataFactory.createTestData(1000);
  //   }

  //   @IsTest
  //   static void testGetFlightsByDateAndKeyword() {
  //     Date preferredDate = Date.today();
  //     String keyword = 'FL';

  //     Test.startTest();
  //     List<Flight__c> flights = FlightRepository.getFlightsByDateAndKeyword(preferredDate, keyword);
  //     Test.stopTest();

  //     System.assertEquals(1000, flights.size(), 'Incorrect number of flights returned.');

  //     for (Flight__c flight : flights) {
  //       // Perform assertions on each flight record as needed
  //       System.assertEquals('FL', flight.Flight_Number__c.substring(0, 2), 'Incorrect flight number format.');
  //       System.assertEquals(preferredDate, flight.Start__c.date(), 'Incorrect flight start date.');
  //     }
  //   }

  //   @IsTest
  //   static void testGetFlightById() {
  //     List<Flight__c> flights = [SELECT Id FROM Flight__c LIMIT 1];
  //     System.assertNotEquals(0, flights.size(), 'No flights found for testing.');

  //     Test.startTest();
  //     Flight__c flight = FlightRepository.getFlightById(flights[0].Id);
  //     Test.stopTest();

  //     System.assertNotEquals(null, flight, 'Flight record not retrieved.');
  //     System.assertEquals(flights[0].Id, flight.Id, 'Incorrect flight record retrieved.');
  //   }

  //   @IsTest
  //   static void testBookFlightForTrip() {
  //     List<Trip__c> trips = [SELECT Id, Contact__c, Status__c FROM Trip__c LIMIT 1];
  //     List<Flight__c> flights = [SELECT Id FROM Flight__c WHERE Id NOT IN (SELECT Flight__c FROM Ticket__c WHERE Contact__c != NULL) LIMIT 1];

  //     System.assertNotEquals(0, trips.size(), 'No trips found for testing.');
  //     System.assertNotEquals(0, flights.size(), 'No available flights found for testing.');

  //     Trip__c trip = trips[0];
  //     Flight__c flight = flights[0];

  //     Test.startTest();
  //     Ticket__c bookedTicket = FlightRepository.bookFlightForTrip(trip.Id, flight.Id);
  //     Test.stopTest();

  //     System.assertNotEquals(null, bookedTicket, 'Ticket not booked.');
  //     System.assertEquals(trip.Contact__c, bookedTicket.Contact__c, 'Incorrect contact on booked ticket.');
  //     System.assertEquals('Flight booked', trip.Status__c, 'Trip status not updated to "Flight booked".');
  //     System.assertEquals(flight.Id, trip.Flight__c, 'Incorrect flight on trip.');

  //     // Ensure the booked ticket is no longer available
  //     List<Ticket__c> availableTickets = [SELECT Id FROM Ticket__c WHERE Flight__c = :flight.Id AND Contact__c = NULL];
  //     System.assertEquals(0, availableTickets.size(), 'Available ticket still found after booking.');
  //   }

  //   // @IsTest
  //   // static void testGetFlightDetailsByTripId() {
  //   //   List<Trip__c> trips = [SELECT Id, Contact__c, Flight__c FROM Trip__c LIMIT 1];
  //   //   System.assertNotEquals(0, trips.size(), 'No trips found for testing.');

  //   //   Trip__c trip = trips[0];

  //   //   Test.startTest();
  //   //   FlightRepository.FlightDetailsWrapper flightDetails = FlightRepository.getFlightDetailsByTripId(trip.Id);
  //   //   Test.stopTest();

  //   //   if (trip.Flight__c != null) {
  //   //     Flight__c flight = [SELECT Flight_Number__c, Start__c FROM Flight__c WHERE Id = :trip.Flight__c LIMIT 1];

  //   //     if (flight != null) {
  //   //       System.assertEquals(flight.Flight_Number__c, flightDetails.flightNumber, 'Incorrect flight number.');
  //   //       System.assertEquals(String.valueOf(flight.Start__c), flightDetails.flightStart, 'Incorrect flight start date.');
  //   //     }
  //   //   }
  //   // }
  // }
}
