const { DatabaseError } = require('../../main/tools/errors/databaseError');
const { ValidationError } = require('../../main/tools/errors/validationError');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { queryPromise } = require('../../main/tools/database/queryPromise');

const { deleteAlarmNotificationsForReminder } = require('../../main/tools/notifications/alarm/deleteAlarmNotification');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteReminderForFamilyIdDogIdReminderId = async (req, familyId, dogId, reminderId) => {
  try {
    const dogLastModified = new Date();
    const reminderLastModified = dogLastModified;

    if (areAllDefined(req, familyId, dogId, reminderId) === false) {
      throw new ValidationError('req, familyId, dogId, or reminderId missing', 'ER_VALUES_MISSING');
    }

    // deletes reminder
    await queryPromise(
      req,
      'UPDATE dogReminders SET reminderIsDeleted = 1, reminderLastModified = ? WHERE reminderId = ?',
      [reminderLastModified, reminderId],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );

    // everything here succeeded so we shoot off a request to delete the alarm notification for the reminder
    deleteAlarmNotificationsForReminder(familyId, reminderId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Queries the database to delete all reminders for a dogId. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteAllRemindersForFamilyIdDogId = async (req, familyId, dogId) => {
  try {
    const dogLastModified = new Date();
    const reminderLastModified = dogLastModified;

    if (areAllDefined(req, familyId, dogId) === false) {
      throw new ValidationError('req, familyId, or dogId missing', 'ER_VALUES_MISSING');
    }

    // find all the reminderIds
    const reminders = await queryPromise(
      req,
      'SELECT reminderId FROM dogReminders WHERE reminderIsDeleted = 0 AND dogId = ? LIMIT 18446744073709551615',
      [dogId],
    );

    // deletes reminders
    await queryPromise(
      req,
      'UPDATE dogReminders SET reminderIsDeleted = 1, reminderLastModified = ? WHERE dogId = ?',
      [reminderLastModified, dogId],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );

    // iterate through all reminders provided to update them all
    // if there is a problem, then we return that problem (function that invokes this will roll back requests)
    // if there are no problems with any of the reminders, we return.
    for (let i = 0; i < reminders.length; i += 1) {
      const reminderId = reminders[i].reminderId;

      // everything here succeeded so we shoot off a request to delete the alarm notification for the reminder
      deleteAlarmNotificationsForReminder(familyId, reminderId);
    }
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteReminderForFamilyIdDogIdReminderId, deleteAllRemindersForFamilyIdDogId };
