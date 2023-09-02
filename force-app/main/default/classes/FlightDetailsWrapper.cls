public with sharing class FlightDetailsWrapper {
  @AuraEnabled
  public Id flightId { get; set; }
  @AuraEnabled
  public String flightNumber { get; set; }
  @AuraEnabled
  public String flightStart { get; set; }
  @AuraEnabled
  public Id ticketId { get; set; }
  @AuraEnabled
  public String ticketName { get; set; }
  @AuraEnabled
  public String ticketNumber { get; set; }
}

// @wire(getRecord, {
//   recordId: "$recordId",
//   fields: [Related_Period_Id__c, Related_package_id__c, OpenPackageOnBo__c],
// })
// handleOpportunityData(wireResult) {
//   const { error, data } = wireResult;
//   this.isBoth = false;
//   this.isPackageOnly = false;
//   this.isToCreate = false;
//   this.isWeired = false;
//   if (data) {
//     const hasPackage = !!getFieldValue(data, Related_package_id__c);
//     const hasPeriod = !!getFieldValue(data, Related_Period_Id__c);
//     this.isBoth = hasPackage && hasPeriod;
//     this.isisPackage = hasPackage && !hasPeriod;
//     this.isToCreate = !hasPackage && !hasPeriod;
//     this.isWeired = !hasPackage && hasPeriod;
//     this.openPackageOnBo = getFieldValue(data, OpenPackageOnBo__c);
//   }
//   this.error = error;
//   console.log('ERROR: ' + this.error);
// }

