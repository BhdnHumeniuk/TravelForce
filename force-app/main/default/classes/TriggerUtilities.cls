public class TriggerUtilities {
  public static Boolean isActiveTrigger(string triggerName) {
    List<Trigger_Setting__mdt> triggerSettings = [SELECT Id, MasterLabel, Active__c FROM Trigger_Setting__mdt WHERE MasterLabel = :triggerName];
    Boolean isActive = false;
    if (!triggerSettings.isEmpty()) {
      isActive = triggerSettings[0].Active__c;
    }
    return isActive;
  }
}