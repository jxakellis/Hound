const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/queryDatabase');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

// Select every column except for dogId, reminderExecutionDate, and reminderLastModified (by not transmitting, increases network efficiency)
// dogId is already known, reminderExecutionDate is calculated client-side and server-side is only used for notification sending, and reminderLastModified has no use client-side
const dogRemindersColumns = 'reminderId, reminderAction, reminderCustomActionName, reminderType, reminderIsEnabled, reminderExecutionBasis, reminderIsDeleted, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed, countdownExecutionInterval, countdownIntervalElapsed, weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, weeklyIsSkipping, weeklyIsSkippingDate, monthlyDay, monthlyHour, monthlyMinute, monthlyIsSkipping, monthlyIsSkippingDate, oneTimeDate';

/**
 *  If the query is successful, returns the reminder for the reminderId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getReminderForReminderId(connection, reminderId, lastDogManagerSynchronization) {
  if (areAllDefined(connection, reminderId) === false) {
    throw new ValidationError('connection or reminderId missing', global.constant.error.value.MISSING);
  }

  const castedLastDogManagerSynchronization = formatDate(lastDogManagerSynchronization);

  const result = areAllDefined(castedLastDogManagerSynchronization)
    ? await databaseQuery(
      connection,
      `SELECT ${dogRemindersColumns} FROM dogReminders WHERE reminderLastModified >= ? AND reminderId = ? LIMIT 1`,
      [castedLastDogManagerSynchronization, reminderId],
    )
    : await databaseQuery(
      connection,
      `SELECT ${dogRemindersColumns} FROM dogReminders WHERE reminderId = ? LIMIT 1`,
      [reminderId],
    );

  // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
  // its unnecessary processing and its easier for the reminders to remember their old states
  return result;
}

/**
 *  If the query is successful, returns an array of all the reminders for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getAllRemindersForDogId(connection, dogId, lastDogManagerSynchronization) {
  if (areAllDefined(connection, dogId) === false) {
    throw new ValidationError('connection or dogId missing', global.constant.error.value.MISSING);
  }

  const castedLastDogManagerSynchronization = formatDate(lastDogManagerSynchronization);

  const result = areAllDefined(castedLastDogManagerSynchronization)
    ? await databaseQuery(
      connection,
      `SELECT ${dogRemindersColumns} FROM dogReminders WHERE reminderLastModified >= ? AND dogId = ? LIMIT 18446744073709551615`,
      [castedLastDogManagerSynchronization, dogId],
    )
    : await databaseQuery(
      connection,
      `SELECT ${dogRemindersColumns} FROM dogReminders WHERE dogId = ? LIMIT 18446744073709551615`,
      [dogId],
    );

  // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
  // its unnecessary processing and its easier for the reminders to remember their old states
  return result;
}

module.exports = { getReminderForReminderId, getAllRemindersForDogId };
