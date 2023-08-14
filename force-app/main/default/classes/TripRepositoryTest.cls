@IsTest
private class TripRepositoryTest {
  // @TestSetup
  // static void setupTestData() {
  //   TestDataFactory.createTestData(1); // Reduced to 1 record for simplicity
  // }

  // @IsTest
  // static void testCancelBookingFlightByTripId() {
  //   List<Trip__c> trips = [SELECT Id, Flight__c, Contact__c, Status__c FROM Trip__c LIMIT 1];

  //   if (!trips.isEmpty()) {
  //     Trip__c trip = trips[0];
  //     trip.Status__c = 'Flight booked';
  //     update trip;

  //     Test.startTest();
  //     TripRepository.cancelBookingFlightByTripId(trip.Id);
  //     Test.stopTest();

  //     List<Trip__c> updatedTrips = [SELECT Id, Flight__c, Status__c FROM Trip__c WHERE Id = :trip.Id];
  //     Trip__c updatedTrip = updatedTrips[0];
  //     System.assertEquals('Flight search', updatedTrip.Status__c);
  //     System.assertEquals(null, updatedTrip.Flight__c);
  //   }
  // }

  // @IsTest
  // static void testUpdateTrip() {
  //   List<Trip__c> trips = [SELECT Id, Status__c FROM Trip__c LIMIT 1];

  //   if (!trips.isEmpty()) {
  //     Trip__c trip = trips[0];
  //     trip.Status__c = 'Flight search';

  //     Test.startTest();
  //     TripRepository.updateTrip(trip);
  //     Test.stopTest();

  //     Trip__c updatedTrip = [SELECT Id, Status__c FROM Trip__c WHERE Id = :trip.Id];
  //     System.assertEquals('Flight search', updatedTrip.Status__c);
  //   }
  // }
}
