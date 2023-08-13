public with sharing class TicketRepository {
  public static Ticket__c getTicketById(Id ticketId) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c WHERE Id = :ticketId LIMIT 1];
  }

  public static List<Ticket__c> getAvailableTicketsByFlightId(Id flightId) {
    return [SELECT Id, Name, Contact__c, Contact__r.Name FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = NULL LIMIT 1];
  }

  public static List<Ticket__c> getTicketsByFlightIdAndContactId(Id flightId, Id contactId) {
    return [SELECT Id, Name, Ticket_Number__c, Contact__c FROM Ticket__c WHERE Flight__c = :flightId AND Contact__c = :contactId LIMIT 1];
  }

  public static void updateTicket(Ticket__c tiket) {
    try {
      update tiket;
    } catch (Exception e) {
      throw new AuraHandledException('Error occurred while updating tickets: ' + e.getMessage());
    }
  }
}
