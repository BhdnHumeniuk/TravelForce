public with sharing class FlightRepository {
  public static List<Flight__c> getFlightsByDateAndKeyword(Date preferredDate, String keyword) {
    DateTime startOfDay = DateTime.newInstance(preferredDate, Time.newInstance(0, 0, 0, 0));
    DateTime endOfDay = DateTime.newInstance(preferredDate, Time.newInstance(23, 59, 59, 999));

    return [
      SELECT Id, Flight_Number__c, Start__c
      FROM Flight__c
      WHERE Start__c >= :startOfDay AND Start__c <= :endOfDay AND Id NOT IN (SELECT Flight__c FROM Ticket__c WHERE Contact__c = NULL) AND Name LIKE :('%' + keyword + '%')
    ];
  }
}
