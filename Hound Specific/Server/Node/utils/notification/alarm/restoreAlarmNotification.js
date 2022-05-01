const { alarmLogger } = require('../../logging/pino');
const { schedule } = require('./schedules');
const { createAlarmNotificationForFamily } = require('./createAlarmNotification');

const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

/**
 * Assumes an empty schedule
 * Restores all of the notifications for the primarySchedule and secondarySchedule
 * Use if the schedule gets destroyed (e.g. server crashes/restarts)
 */
const restoreAlarmNotificationsForAllFamilies = async () => {
  alarmLogger.debug('restoreAlarmNotificationsForAll');

  try {
    // remove any pending jobs (there shouldn't be any)
    for (const key of Object.keys(schedule.scheduledJobs)) {
      schedule.scheduledJobs[key].cancel();
    }

    // for ALL reminders get: familyId, reminderId, dogName, reminderExecutionDate, reminderAction, and reminderCustomActionName
    const remindersWithInfo = await queryPromise(
      connectionForNotifications,
      'SELECT dogs.familyId, dogReminders.reminderId, dogReminders.reminderExecutionDate FROM dogReminders JOIN dogs ON dogs.dogId = dogReminders.dogId WHERE dogReminders.reminderExecutionDate IS NOT NULL',
    );
    // for every reminder that exists (with a valid reminderExecutionDate), we invoke createAlarmNotificationForAll for it
    for (let i = 0; i < remindersWithInfo.length; i += 1) {
      alarmLogger.debug(`Recreating notification ${JSON.stringify(remindersWithInfo[i])}`);
      // get individual information for a family
      const alarmNotificationInformation = remindersWithInfo[i];
      // restore generic alarm for family for given reminder , this function will also restore the follow up notifications for all users
      // no need to await, let it go
      createAlarmNotificationForFamily(
        alarmNotificationInformation.familyId,
        alarmNotificationInformation.reminderId,
        alarmNotificationInformation.reminderExecutionDate,
      );
    }
  }
  catch (error) {
    alarmLogger.error(`restoreAlarmNotificationsForAll error: ${JSON.stringify(error)}`);
  }
};

module.exports = {
  restoreAlarmNotificationsForAllFamilies,
};
