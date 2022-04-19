const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/database/queryPromise');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteReminderQuery = async (req, reminderId) => {
  try {
    // deletes all components
    await queryPromise(req, 'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId]);
    await queryPromise(req, 'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId]);
    // deletes reminder
    await queryPromise(req, 'DELETE FROM dogReminders WHERE reminderId = ?', [reminderId]);
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
const deleteRemindersQuery = async (req, reminders) => {
  // iterate through all reminders provided to update them all
  // if there is a problem, then we return that problem (function that invokes this will roll back requests)
  // if there are no problems with any of the reminders, we return.
  for (let i = 0; i < reminders.length; i += 1) {
    const reminderId = reminders[i].reminderId;

    await deleteReminderQuery(req, reminderId);
  }
};

module.exports = { deleteReminderQuery, deleteRemindersQuery };
