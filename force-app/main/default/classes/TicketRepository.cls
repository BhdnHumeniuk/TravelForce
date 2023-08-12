public with sharing class TicketRepository {
  public static Ticket__c getTicketById(Id ticketId) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c WHERE Id = :ticketId LIMIT 1];
  }
}
