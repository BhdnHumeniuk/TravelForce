public with sharing class FlightDetailsWrapper {
  @AuraEnabled
  public String flightNumber { get; set; }
  @AuraEnabled
  public String flightStart { get; set; }
  @AuraEnabled
  public String ticketName { get; set; }
  @AuraEnabled
  public String ticketNumber { get; set; }
}
