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

  @IsTest
  static void testGetTripsByIds() {
    Set<Id> tripIds = new Set<Id>();
    List<Trip__c> trips = [SELECT Id FROM Trip__c LIMIT 5];
    for (Trip__c trip : trips) {
      tripIds.add(trip.Id);
    }

    List<Trip__c> retrievedTrips = TripRepository.getTripsByIds(tripIds);

    System.assertEquals(5, retrievedTrips.size());
  }

  @IsTest
  static void testGetTripsByFlightId() {
    List<Flight__c> flights = [SELECT Id FROM Flight__c LIMIT 1];
    Id flightId = flights[0].Id;

    List<Trip__c> retrievedTrips = TripRepository.getTripsByFlightId(flightId);

    System.assertNotEquals(0, retrievedTrips.size());
  }

  @IsTest
  static void testUpdateTrips() {
    List<Trip__c> tripsToUpdate = [SELECT Id, Status__c FROM Trip__c LIMIT 5];
    for (Trip__c trip : tripsToUpdate) {
      trip.Status__c = 'Flight booked';
    }

    Test.startTest();
    TripRepository.updateTrips(tripsToUpdate);
    Test.stopTest();

    List<Trip__c> updatedTrips = [SELECT Id, Status__c FROM Trip__c WHERE Id IN :tripsToUpdate];
    for (Trip__c updatedTrip : updatedTrips) {
      System.assertEquals('Flight booked', updatedTrip.Status__c);
    }
  }
}
