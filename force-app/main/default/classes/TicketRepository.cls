public with sharing class TicketRepository {
  public static List<Ticket__c> getTicketsByIds(Set<Id> ticketIds) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c WHERE Id IN :ticketIds];
  }

  public static List<Ticket__c> getAvailableTicketsByFlightId(Id flightId) {
    return [SELECT Id, Name, Contact__c, Contact__r.Name FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = NULL];
  }

  public static Ticket__c getTicketsByFlightIdAndContactId(Id flightId, Id contactId) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__c FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = :contactId LIMIT 1];
  }

  public static void updateTickets(List<Ticket__c> tikets) {
    try {
      update tikets;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating tickets: ' + e.getMessage());
    }
  }
}
