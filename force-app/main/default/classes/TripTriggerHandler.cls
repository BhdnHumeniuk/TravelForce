public with sharing class TripTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<sObject> newList) {
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
  }

  public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    List<Trip__c> newTripList = (List<Trip__c>) newList;
    List<Trip__c> tripsToBook = new List<Trip__c>();
    List<Trip__c> tripsToCancel = new List<Trip__c>();

    for (Trip__c newTrip : newTripList) {
      Trip__c oldTrip = (Trip__c) oldMap.get(newTrip.Id);
      if (newTrip.Status__c != oldTrip.Status__c) {
        if (newTrip.Status__c == 'Flight Booked') {
          tripsToBook.add(newTrip);
        } else if (newTrip.Status__c == 'Flight search') {
          tripsToCancel.add(oldTrip);
        }
      }
      if (newTrip.Preferred_Trip_Start__c != oldTrip.Preferred_Trip_Start__c) {
        TripUpdatedEvent__e event = new TripUpdatedEvent__e(TripId__c = newTrip.Id, NewPreferredTripStart__c = newTrip.Preferred_Trip_Start__c);
        EventBus.publish(event);
        System.debug('Send Platform Event' + event);
      }
    }

    if (!tripsToBook.isEmpty()) {
      FlightController.bookFlight(tripsToBook);
    } else if (!tripsToCancel.isEmpty()) {
      FlightController.cancelBookingFlight(tripsToCancel);
    }
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    List<Trip__c> oldTripList = (List<Trip__c>) oldList;
    FlightController.cancelBookingFlight(oldTripList);
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
  }
}