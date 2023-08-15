@IsTest
public with sharing class TicketCalloutServiceTest {
  @TestSetup
  static void setupTestData() {
    List<Contact> contacts = TestDataFactory.createContacts(1);
    List<Flight__c> flights = TestDataFactory.createFlights(1);
    List<Ticket__c> tickets = TestDataFactory.createTickets(1, flights);
  }

  @IsTest
  static void testSendMessageToExternalAPI() {
    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());

    List<Ticket__c> tickets = [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c LIMIT 1];
    Set<Id> ticketIds = new Set<Id>{ tickets[0].Id };

    Test.startTest();
    TicketCalloutService.sendMessageToExternalAPI(ticketIds);
    Test.stopTest();
  }
}
