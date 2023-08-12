public with sharing class FlightController {
  @AuraEnabled(cacheable=true)
  public static List<Flight__c> getAvailableFlightsWithKeyword(Id recordId, String searchKeyword) {
    Date preferredDate = tripRepository.getPreferredDateByRecordId(recordId);
    return FlightRepository.getFlightsByDateAndKeyword(preferredDate, searchKeyword);
  }

  @AuraEnabled
  public static void bookFlight(Id tripId, Id flightId) {
    try {
      Ticket__c ticket = FlightRepository.bookFlightForTrip(tripId, flightId);
      sendMessageToExternalAPI(ticket.Id);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @future(callout=true)
  public static void sendMessageToExternalAPI(Id ticketId) {
    Ticket__c ticket = TicketRepository.getTicketById(ticketId);
    if (ticket != null) {
      String API_BASE_URL = 'https://private-1ce70-testassign.apiary-mock.com'; //Its endpoint was specified in the task description
      String API_BASE_URL_INSPECTOR = 'https://private-anon-ee2aae1b9f-testassign.apiary-mock.com'; //Its endpoint I got from documentation in "Inspector" section
      String endpointUrl = API_BASE_URL_INSPECTOR + '/ticket';

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
