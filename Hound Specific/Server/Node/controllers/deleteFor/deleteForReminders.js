const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/database/queryPromise');

const { deleteAlarmNotificationsForReminder } = require('../../utils/notification/alarm/deleteAlarmNotification');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteReminderQuery = async (req, userId, familyId, reminderId) => {
  try {
    // deletes all components
    await queryPromise(req, 'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId]);
    // deletes reminder
    await queryPromise(req, 'DELETE FROM dogReminders WHERE reminderId = ?', [reminderId]);
    // everything here succeeded so we shoot off a request to delete the alarm notification for the reminder
    deleteAlarmNotificationsForReminder(familyId, reminderId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Queries the database to delete multiple reminders. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteRemindersQuery = async (req, userId, familyId, reminders) => {
  // iterate through all reminders provided to update them all
  // if there is a problem, then we return that problem (function that invokes this will roll back requests)
  // if there are no problems with any of the reminders, we return.
  for (let i = 0; i < reminders.length; i += 1) {
    const reminderId = reminders[i].reminderId;

    await deleteReminderQuery(req, userId, familyId, reminderId);
  }
};

module.exports = { deleteReminderQuery, deleteRemindersQuery };
