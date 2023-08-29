@IsTest
private class TicketRepositoryTest {
  @TestSetup
  static void setupTestData() {
    List<Flight__c> flights = TestDataFactory.createFlights(100);
    List<Ticket__c> tickets = TestDataFactory.createTickets(1000, flights);
  }

  @IsTest
  static void testGetTicketsByIds() {
    List<Ticket__c> testTickets = [SELECT Id, Name, Ticket_Number__c, Contact__r.Name FROM Ticket__c LIMIT 5];
    Set<Id> ticketIds = new Set<Id>();
    Map<Id, Ticket__c> expectedTickets = new Map<Id, Ticket__c>();

    for (Ticket__c ticket : testTickets) {
      ticketIds.add(ticket.Id);
      expectedTickets.put(ticket.Id, ticket);
    }

    Test.startTest();
    List<Ticket__c> retrievedTickets = TicketRepository.getTicketsByIds(ticketIds);
    Test.stopTest();

    System.assertEquals(testTickets.size(), retrievedTickets.size());

    for (Ticket__c retrievedTicket : retrievedTickets) {
      Ticket__c expectedTicket = expectedTickets.get(retrievedTicket.Id);
      System.assertEquals(expectedTicket.Id, retrievedTicket.Id);
      System.assertEquals(expectedTicket.Name, retrievedTicket.Name);
      System.assertEquals(expectedTicket.Ticket_Number__c, retrievedTicket.Ticket_Number__c);
      System.assertEquals(expectedTicket.Contact__r.Name, retrievedTicket.Contact__r.Name);
    }
  }

  @IsTest
  static void testGetTicketsByFlightId() {
    Flight__c testFlight = [SELECT Id FROM Flight__c LIMIT 1];
    List<Contact> contacts = TestDataFactory.createContacts(10);

    Test.startTest();
    List<Ticket__c> availableTickets = TicketRepository.getTicketsByFlightId(testFlight.Id);
    System.assertEquals(10, availableTickets.size());

    for (Integer i = 0; i < availableTickets.size(); i++) {
      availableTickets[i].Contact__c = contacts[i].Id;
    }
    update availableTickets;

    availableTickets = TicketRepository.getTicketsByFlightId(testFlight.Id);
    System.assertEquals(0, availableTickets.size());
    Test.stopTest();
  }

  // @IsTest
  // static void testGetTicketsByFlightIdAndContactId() {
  //   List<Contact> contacts = TestDataFactory.createContacts(1);
  //   List<Ticket__c> tickets = [SELECT Id, Flight__c FROM Ticket__c LIMIT 1];

  //   List<Ticket__c> ticketsToAssign = new List<Ticket__c>();
  //   for (Ticket__c ticket : tickets) {
  //     ticketsToAssign.add(ticket);
  //   }
  //   List<Flight__c> bookedFlights = TestDataFactory.assignContactsToTickets(ticketsToAssign, contacts);

  //   Test.startTest();
  //   List<Ticket__c> retrievedTickets = TicketRepository.getTicketsByFlightIdAndContactId(bookedFlights[0].Id, contacts[0].Id);
  //   Test.stopTest();

  //   System.assertNotEquals(0, retrievedTickets.size());
  // }

  @IsTest
  static void testUpdateTickets() {
    List<Ticket__c> testTickets = [SELECT Id, Contact__c, Name FROM Ticket__c LIMIT 5];
    Contact newContact = new Contact(FirstName = 'Test', LastName = 'Contact');
    insert newContact;

    for (Ticket__c testTicket : testTickets) {
      testTicket.Contact__c = newContact.Id;
    }

    Test.startTest();
    TicketRepository.updateTickets(testTickets);
    Test.stopTest();

    List<Ticket__c> updatedTickets = [SELECT Id, Contact__c FROM Ticket__c WHERE Id IN :testTickets];
    System.assertEquals(testTickets.size(), updatedTickets.size());

    for (Integer i = 0; i < testTickets.size(); i++) {
      Ticket__c testTicket = testTickets[i];
      Ticket__c updatedTicket = updatedTickets[i];
      System.assertEquals(testTicket.Contact__c, updatedTicket.Contact__c);
    }
  }
}
