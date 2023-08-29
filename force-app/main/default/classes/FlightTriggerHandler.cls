public class FlightTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<sObject> newList) {
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
  }

  public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    List<Flight__c> oldFlightList = (List<Flight__c>) oldList;
    List<Ticket__c> allTicketsToDelete = new List<Ticket__c>();

    for (Flight__c flight : oldFlightList) {
      List<Ticket__c> ticketsToDelete = TicketRepository.getTicketsByFlightId(flight.Id);
      for (Ticket__c ticket : ticketsToDelete) {
        allTicketsToDelete.add(ticket);
      }
    }
    TicketRepository.deleteTickets(allTicketsToDelete);
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
  }
}
