public with sharing class TripController {
  @AuraEnabled(cacheable=true)
  public static Boolean isTripBookedFlight(Id tripId) {
    Set<Id> tripIds = new Set<Id>{ tripId };
    List<Trip__c> trips = TripRepository.getTripsByIds(tripIds);
    String tripStatus = trips[0].Status__c;
    if (tripStatus != null) {
      if (tripStatus == 'Flight booked') {
        return true;
      } else if (tripStatus == 'Flight search') {
        return false;
      } else {
        throw new AuraHandledException('Invalid trip status.');
      }
    } else {
      throw new AuraHandledException('Trip not found.');
    }
  }

  @AuraEnabled
  public static void changeStatusTripToBook(Id tripId, Id flightId) {
    try {
      Trip__c trip = TripRepository.getTripsByIds(new Set<Id>{ tripId })[0];
      Flight__c flight = FlightRepository.getFlightsByIds(new Set<Id>{ flightId })[0];

      if (trip == null || flight == null) {
        throw new AuraHandledException('Invalid trip or flight ID.');
      }

      trip.Flight__c = flightId;
      trip.Status__c = 'Flight booked';
      TripRepository.updateTrips(new List<Trip__c>{ trip });
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static void changeStatusTripToFree(Id tripId) {
    try {
      Trip__c trip = TripRepository.getTripsByIds(new Set<Id>{ tripId })[0];

      if (trip == null || trip.Status__c != 'Flight booked') {
        throw new AuraHandledException('Invalid trip data for flight rejection.');
      }

      trip.Flight__c = null;
      trip.Status__c = 'Flight search';
      TripRepository.updateTrips(new List<Trip__c>{ trip });
    } catch (Exception e) {
      throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
  }
}
