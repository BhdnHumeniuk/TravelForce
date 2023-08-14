public with sharing class TicketCalloutService {
  @future(callout=true)
  public static void sendMessageToExternalAPI(Set<Id> ticketIds) {
    List<Ticket__c> tickets = TicketRepository.getTicketsByIds(ticketIds);

    if (tickets != null) {
      Confirmation_ticket_setting__c customSetting = Confirmation_ticket_setting__c.getInstance();

      String endpointUrl;
      if (customSetting != null && !String.isBlank(customSetting.URL__c)) {
        endpointUrl = customSetting.URL__c;
      } else {
        endpointUrl = 'https://private-1ce70-testassign.apiary-mock.com ' + '/ticket';
      }

      for (Ticket__c ticket : tickets) {
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('ticketnumber', ticket.Ticket_Number__c);
        requestBodyMap.put('contact', ticket.Contact__r.Name);
        String requestBody = JSON.serialize(requestBodyMap);
        HttpResponse response = CalloutService.makePostCallout(endpointUrl, requestBody);

        if (response.getStatusCode() == 201) {
          System.debug('Callout successful. Response: ' + response.getBody());
        } else {
          System.debug('Callout failed with error. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
        }
      }
    }
  }
}
