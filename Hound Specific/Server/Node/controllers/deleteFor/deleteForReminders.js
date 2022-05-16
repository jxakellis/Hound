const DatabaseError = require('../../main/tools/errors/databaseError');
const { queryPromise } = require('../../main/tools/database/queryPromise');

const { deleteAlarmNotificationsForReminder } = require('../../main/tools/notifications/alarm/deleteAlarmNotification');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteReminderQuery = async (req, familyId, reminderId) => {
  try {
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
const deleteRemindersQuery = async (req, familyId, reminders) => {
  // iterate through all reminders provided to update them all
  // if there is a problem, then we return that problem (function that invokes this will roll back requests)
  // if there are no problems with any of the reminders, we return.
  for (let i = 0; i < reminders.length; i += 1) {
    const reminderId = reminders[i].reminderId;

    await deleteReminderQuery(req, familyId, reminderId);
  }
};

module.exports = { deleteReminderQuery, deleteRemindersQuery };
