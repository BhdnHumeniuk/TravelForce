public class TriggerDispatcher {
  public static void run(ITriggerHandler handler, string triggerName) {
    Boolean isActive = TriggerUtilities.isActiveTrigger(triggerName);

    if (isActive) {
      switch on Trigger.operationType {
        when BEFORE_INSERT {
          handler.beforeInsert(Trigger.new);
          System.debug('beforeInsert ' + triggerName);
        }
        when AFTER_INSERT {
          handler.afterInsert(Trigger.new, Trigger.newMap);
          System.debug('afterInsert ' + triggerName);
        }
        when BEFORE_UPDATE {
          handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
          System.debug('beforeUpdate ' + triggerName);
        }
        when AFTER_UPDATE {
          handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
          System.debug('afterUpdate ' + triggerName);
        }
        when BEFORE_DELETE {
          handler.beforeDelete(Trigger.old, Trigger.oldMap);
          System.debug('beforeDelete ' + triggerName);
        }
        when AFTER_DELETE {
          handler.afterDelete(Trigger.old, Trigger.oldMap);
          System.debug('afterDelete ' + triggerName);
        }
        when AFTER_UNDELETE {
          handler.afterUnDelete(Trigger.new, Trigger.newMap);
          System.debug('afterUnDelete ' + triggerName);
        }
      }
    }
  }
}
