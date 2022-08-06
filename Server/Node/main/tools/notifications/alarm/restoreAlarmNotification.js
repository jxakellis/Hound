const { serverLogger } = require('../../logging/loggers');
const { schedule } = require('./schedules');
const { createAlarmNotificationForFamily } = require('./createAlarmNotification');

const { logServerError } = require('../../logging/logServerError');
const { serverConnectionForAlarms } = require('../../database/databaseConnections');
const { databaseQuery } = require('../../database/databaseQuery');

/**
 * Assumes an empty schedule
 * Restores all of the notifications for the primarySchedule and secondarySchedule
 * Use if the schedule gets destroyed (e.g. server crashes/restarts)
 */
async function restoreAlarmNotificationsForAllFamilies() {
  try {
    serverLogger.debug('restoreAlarmNotificationsForAll');

    // remove any pending jobs (there shouldn't be any)
    for (const key of Object.keys(schedule.scheduledJobs)) {
      schedule.scheduledJobs[key].cancel();
    }

    // for ALL reminders get: familyId, reminderId, dogName, reminderExecutionDate, reminderAction, and reminderCustomActionName
    const remindersWithInfo = await databaseQuery(
      serverConnectionForAlarms,
      'SELECT dogs.familyId, dogReminders.reminderId, dogReminders.reminderExecutionDate FROM dogReminders JOIN dogs ON dogs.dogId = dogReminders.dogId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND dogReminders.reminderExecutionDate IS NOT NULL LIMIT 18446744073709551615',
    );
    // for every reminder that exists (with a valid reminderExecutionDate), we invoke createAlarmNotificationForAll for it
    for (let i = 0; i < remindersWithInfo.length; i += 1) {
      serverLogger.debug(`Recreating notification ${JSON.stringify(remindersWithInfo[i])}`);
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
    logServerError('restoreAlarmNotificationsForAll', error);
  }
}

module.exports = {
  restoreAlarmNotificationsForAllFamilies,
};
