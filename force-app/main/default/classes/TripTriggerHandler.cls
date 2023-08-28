public with sharing class TripTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<sObject> newList) {
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
  }

  public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    // List<Trip__c> newTripList = newList;
    // for (Trip__c newTrip : newTripList) {
    //   Trip__c oldTrip = (Trip__c) oldMap.get(newTrip.Id);
    //   Flight__c bookedFlight = FlightRepository.getAndValidateBookedFlight(oldTrip.Flight__c);
    //   List<Ticket__c> bookedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlight.Id, oldTrip.Contact__c);
    //   if (newTrip.Status__c != oldTrip.Status__c && newTrip.Status__c == 'Flight Booked') {
    //     if (bookedTickets.isEmpty()) {
    //       System.debug('Change from free to booked');
    //       if (oldTrip.Flight__c == null) {
    //         FlightController.bookFlight(newTrip.Id, newTrip.Flight__c);
    //       }
    //     } else if (newTrip.Status__c != oldTrip.Status__c && newTrip.Status__c == 'Flight search') {
    //       if (!bookedTickets.isEmpty()) {
    //         System.debug('Change from booked to free');
    //         if (oldTrip.Flight__c != null) {
    //           FlightController.cancelBookingFlight(oldTrip.Id);
    //         }
    //       }
    //     }
    //   }
    // }
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
  }
}
