public with sharing class TicketRepository {
  public static List<Ticket__c> getTicketsByIds(Set<Id> ticketIds) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c WHERE Id IN :ticketIds];
  }

  public static List<Ticket__c> getTicketsByFlightId(Id flightId) {
    return [SELECT Id, Name, Contact__c, Contact__r.Name FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = NULL];
  }

  public static Ticket__c getTicketByFlightIdAndContactId(Id flightId, Id contactId) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__c FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = :contactId LIMIT 1];
  }

  public static void updateTickets(List<Ticket__c> tickets) {
    try {
      update tickets;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating tickets: ' + e.getMessage());
    }
  }

  public static void deleteTickets(List<Ticket__c> tickets) {
    try {
      delete tickets;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating tickets: ' + e.getMessage());
    }
  }
}