@IsTest
private class TripControllerTest {
  @TestSetup
  static void setupTestData() {
    List<Contact> contacts = TestDataFactory.createContacts(1);
    List<Trip__c> trips = TestDataFactory.createTrips(1, contacts);
  }

  @IsTest
  static void testIsTripBookedFlight_FlightBooked() {
    Trip__c trip = [SELECT Id, Status__c FROM Trip__c LIMIT 1];
    trip.Status__c = 'Flight booked';
    update trip;

    Test.startTest();
    Boolean isBooked = TripController.isTripBookedFlight(trip.Id);
    Test.stopTest();

    System.assertEquals(true, isBooked);
  }

  @IsTest
  static void testIsTripBookedFlight_FlightSearch() {
    Trip__c trip = [SELECT Id, Status__c FROM Trip__c LIMIT 1];
    trip.Status__c = 'Flight search';
    update trip;

    Test.startTest();
    Boolean isBooked = TripController.isTripBookedFlight(trip.Id);
    Test.stopTest();

    System.assertEquals(false, isBooked);
  }

  //   @IsTest
  //   static void testIsTripBookedFlight_InvalidStatus() {
  //     Trip__c trip = [SELECT Id, Status__c FROM Trip__c LIMIT 1];
  //     trip.Status__c = 'Invalid status';
  //     update trip;

  //     Test.startTest();
  //     try {
  //       Boolean isBooked = TripController.isTripBookedFlight(trip.Id);
  //       System.assert(false, 'Exception should have been thrown');
  //     } catch (AuraHandledException e) {
  //       System.assertEquals('Invalid trip status.', e.getMessage());
  //     }
  //     Test.stopTest();
  //   }

  //   @IsTest
  //   static void testIsTripBookedFlight_TripNotFound() {
  //     Test.startTest();
  //     try {
  //       Boolean isBooked = TripController.isTripBookedFlight('invalidTripId');
  //       System.assert(false, 'Exception should have been thrown');
  //     } catch (AuraHandledException e) {
  //       System.assertEquals('Trip not found.', e.getMessage());
  //     }
  //     Test.stopTest();
  //   }
}