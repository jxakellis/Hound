const { alarmLogger } = require('../../logging/pino');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

const {
  formatBoolean, formatNumber, formatDate, areAllDefined,
} = require('../../database/validateFormat');

const { createSecondaryAlarmNotificationForUser } = require('./createAlarmNotification');
const { deleteSecondaryAlarmNotificationsForUser } = require('./deleteAlarmNotification');

// TO DO refresh for edge cases

// Add refresh notifications (aka refresh scheduled jobs) for family,
// this would be invoked when the family toggles isPaused.
// No need to call upon a family delete (as sendAPN checks for user tokens before sending and if the family was deleted then no tokens linked to the familyId)

/**
 * Invoke when the user toggles isFollowUpEnabled or changes followUpDelay
 * Refreshes the date or state of the followUpNotifications for a given user.
 * No need to call upon user delete (as sendAPN checks for user tokens before sending and if the user was deleted then no tokens linked to the userId)
 * No need to call if the user updates their isNotificationEnabled (as sendAPN checks to see if the user is notification enabled before sending)
 */
const refreshSecondaryAlarmNotificationsForUser = async (userId, isFollowUpEnabled, followUpDelay) => {
  alarmLogger.debug(`refreshSecondaryAlarmNotificationsForUser ${userId}, ${isFollowUpEnabled}, ${followUpDelay}`);

  // Have to be careful isFollowUpEnabled and followUpDelay are accessed as there will be uncommited transactions involved
  // If the transaction is uncommited and querying from an outside connection (connectionForNotifications), the values from a SELECT query will be the old values
  // If the transaction is uncommited and querying from the updating connection (req.connection), the values from the SELECT query will be the updated values
  // If the transaction is committed, then any connection will reflect the new values
  let formattedIsFollowUpEnabled = formatBoolean(isFollowUpEnabled);
  let formattedFollowUpDelay = formatNumber(followUpDelay);
  try {
    const result = await queryPromise(
      connectionForNotifications,
      'SELECT isFollowUpEnabled, followUpDelay FROM userConfiguration WHERE userId = ?',
      [userId],
    );

    // handle the case if only one of these parameters was updated, so the the other may be nil.
    if (areAllDefined(formattedIsFollowUpEnabled) === false) {
      formattedIsFollowUpEnabled = formatBoolean(result[0].isFollowUpEnabled);
    }
    if (areAllDefined(formattedFollowUpDelay) === false) {
      formattedFollowUpDelay = formatNumber(result[0].followUpDelay);
    }
    if (areAllDefined([userId, isFollowUpEnabled, followUpDelay])) {
      if (isFollowUpEnabled === false) {
        // follow up is not enabled so we should remove any potential secondary jobs
        await deleteSecondaryAlarmNotificationsForUser(userId);
      }
      else {
        // follow up is enabled and followUpDelay is potentially updated. Therefore destroy any existing secondary jobs and recreate
        await deleteSecondaryAlarmNotificationsForUser(userId);

        // get all the reminders for the given userId
        const remindersWithInfo = await queryPromise(
          connectionForNotifications,
          'SELECT dogReminders.reminderId, dogReminders.reminderExecutionDate FROM dogReminders JOIN dogs ON dogs.dogId = dogReminders.dogId JOIN familyMembers ON dogs.familyId = familyMembers.familyId WHERE familyMembers.userId = ? AND dogReminders.reminderExecutionDate IS NOT NULL',
          [userId],
        );

        // iterate through all the reminders and recreate the follow up notifications
        for (let i = 0; i < remindersWithInfo.length; i += 1) {
          const formattedReminderExecutionDate = formatDate(remindersWithInfo[i].reminderExecutionDate);

          // we have the information for an individual reminder so we can create a new follow up alarm for the user
          createSecondaryAlarmNotificationForUser(
            userId,
            remindersWithInfo[i].reminderId,
            new Date(formattedReminderExecutionDate.getTime() + (followUpDelay * 1000)),
          );
        }
      }
    }
  }
  catch (error) {
    alarmLogger.error(`refreshSecondaryAlarmNotificationsForUser error: ${JSON.stringify(error)}`);
  }
};

module.exports = {
  refreshSecondaryAlarmNotificationsForUser,
};
