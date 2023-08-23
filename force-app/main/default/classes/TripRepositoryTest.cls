@IsTest
private class TripRepositoryTest {
  @TestSetup
  static void setupTestData() {
    List<Contact> contacts = TestDataFactory.createContacts(10);
    List<Flight__c> flights = TestDataFactory.createFlights(10);
    List<Ticket__c> tickets = TestDataFactory.createTickets(100, flights);
    List<Trip__c> trips = TestDataFactory.createTrips(10, contacts);
    List<Trip__c> bookedTrips = TestDataFactory.assignFlightsToTrips(flights, trips);
  }

  // @IsTest
  // static void testCancelBookingFlightByTripId() {
  //   Trip__c bookedTrip = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c WHERE Status__c = 'Flight booked' LIMIT 1];
  //   System.assertNotEquals(null, bookedTrip);

  // Test.startTest();
  // TripRepository.cancelTripBooking(bookedTrip.Id);
  // Test.stopTest();

  //   Trip__c canceledTrip = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c WHERE Id = :bookedTrip.Id];
  //   System.assertEquals(null, canceledTrip.Flight__c);
  //   System.assertEquals('Flight search', canceledTrip.Status__c);

  //   List<Ticket__c> canceledTickets = [SELECT Id, Contact__c FROM Ticket__c WHERE Flight__c = :bookedTrip.Flight__c];
  //   for (Ticket__c canceledTicket : canceledTickets) {
  //     System.assertEquals(null, canceledTicket.Contact__c);
  //   }
  // }

  // @IsTest
  // static void testCancelBookingFlightByTripId_InvalidFlight() {
  //   Trip__c bookedTrip = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c WHERE Status__c = 'Flight booked' LIMIT 1];
  //   System.debug('bookedTrip: ' + bookedTrip);
  //   System.assertNotEquals(null, bookedTrip);

  //   bookedTrip.Flight__c = null;
  //   update bookedTrip;
  //   System.debug('AfterUpdateBookedTrip: ' + bookedTrip);

  //   Test.startTest();
  //   try {
  //     TripRepository.cancelBookingFlightByTripId(bookedTrip.Id);
  //     System.assert(false, 'Expected exception was not thrown');
  //   } catch (AuraHandledException e) {
  //     System.debug('ERROR: ' + e.getMessage());
  //     System.assert(e.getMessage().contains('Invalid booked flight data.'));
  //   }
  //   Test.stopTest();
  // }

  // @IsTest
  // static void testCancelBookingFlightByTripId_InvalidTrip() {
  //   Trip__c trip = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c WHERE Status__c = 'Flight search' LIMIT 1];
  //   System.assertNotEquals(null, trip);

  //   Test.startTest();
  //   try {
  //     TripRepository.cancelBookingFlightByTripId(trip.Id);
  //     System.assert(false, 'Expected exception was not thrown');
  //   } catch (AuraHandledException e) {
  //     System.assert(e.getMessage().contains('Invalid trip data for flight rejection.'));
  //   }
  //   Test.stopTest();
  // }
}
