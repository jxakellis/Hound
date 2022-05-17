const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatNumber, formatDate, formatBoolean, formatArray, areAllDefined,
} = require('../../main/tools/validation/validateFormat');
const { NUMBER_OF_REMINDERS_PER_DOG } = require('../../main/server/constants');

/**
 *  Queries the database to create a single reminder. If the query is successful, then returns the reminder with created reminderId added to it.
 *  If a problem is encountered, creates and throws custom error
 */
const createReminderQuery = async (req, reminder) => {
  const dogId = req.params.dogId;

  if (areAllDefined(dogId, reminder) === false) {
    throw new ValidationError('dogId or reminder missing', 'ER_VALUES_MISSING');
  }

  let numberOfReminders;
  try {
    numberOfReminders = await queryPromise(
      req,
      'SELECT reminderId FROM dogReminders WHERE dogId = ?',
      [dogId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // make sure that the user isn't creating too many reminders
  if (numberOfReminders.length >= NUMBER_OF_REMINDERS_PER_DOG) {
    throw new ValidationError(`Dog reminder limit of ${NUMBER_OF_REMINDERS_PER_DOG} exceeded`, 'ER_REMINDER_LIMIT_EXCEEDED');
  }

  // general reminder components
  const { reminderAction, reminderCustomActionName, reminderType } = reminder; // required
  const reminderIsEnabled = formatBoolean(reminder.reminderIsEnabled); // required
  const reminderExecutionBasis = formatDate(reminder.reminderExecutionBasis); // required
  const reminderExecutionDate = formatDate(reminder.reminderExecutionDate); // optional
  const reminderLastModified = new Date(); // manual

  // countdown components
  const countdownExecutionInterval = formatNumber(reminder.countdownExecutionInterval); // required

  // weekly components
  const weeklyHour = formatNumber(reminder.weeklyHour); // required
  const weeklyMinute = formatNumber(reminder.weeklyMinute); // required
  const weeklySunday = formatBoolean(reminder.weeklySunday); // required
  const weeklyMonday = formatBoolean(reminder.weeklyMonday); // required
  const weeklyTuesday = formatBoolean(reminder.weeklyTuesday); // required
  const weeklyWednesday = formatBoolean(reminder.weeklyWednesday); // required
  const weeklyThursday = formatBoolean(reminder.weeklyThursday); // required
  const weeklyFriday = formatBoolean(reminder.weeklyFriday); // required
  const weeklySaturday = formatBoolean(reminder.weeklySaturday); // required

  // monthly components
  const monthlyHour = formatNumber(reminder.monthlyHour); // required
  const monthlyMinute = formatNumber(reminder.monthlyMinute); // required
  const monthlyDay = formatNumber(reminder.monthlyDay); // required

  // one time components
  const oneTimeDate = formatDate(reminder.oneTimeDate); // required

  // check to see that necessary generic reminder components are present
  if (areAllDefined(reminderAction, reminderType, reminderIsEnabled, reminderExecutionBasis) === false) {
    throw new ValidationError('reminderAction, reminderType, reminderIsEnabled, or reminderExecutionBasis missing', 'ER_VALUES_MISSING');
  }
  else if (reminderType !== 'countdown' && reminderType !== 'weekly' && reminderType !== 'monthly' && reminderType !== 'oneTime') {
    throw new ValidationError('reminderType invalid', 'ER_VALUES_INVALID');
  }
  // no need to check snooze components as a newly created reminder can't be snoozed yet
  // no need to check for countdownIntervalElapsed as newly created reminder couldn't have elapsed time
  else if (areAllDefined(countdownExecutionInterval) === false) {
    throw new ValidationError('countdownExecutionInterval missing', 'ER_VALUES_MISSING');
  }
  // no need to check weeklyIsSkipping && weeklyIsSkippingDate validity as newly created reminder can't be skipped yet
  else if (areAllDefined(weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday) === false) {
    throw new ValidationError('weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, or weeklySaturday missing', 'ER_VALUES_MISSING');
  }
  // no need to check monthlyIsSkipping && monthlyIsSkippingDate validity as newly created reminder can't be skipped yet
  else if (areAllDefined(monthlyDay, monthlyHour, monthlyMinute) === false) {
    throw new ValidationError('monthlyDay, monthlyHour, or monthlyMinute missing', 'ER_VALUES_MISSING');
  }
  else if (areAllDefined(oneTimeDate) === false) {
    throw new ValidationError('oneTimeDate missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogReminders(dogId, reminderAction, reminderCustomActionName, reminderType, reminderIsEnabled, reminderExecutionBasis, reminderExecutionDate, reminderLastModified, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed, countdownExecutionInterval, countdownIntervalElapsed, weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, weeklyIsSkipping, weeklyIsSkippingDate, monthlyDay, monthlyHour, monthlyMinute, monthlyIsSkipping, monthlyIsSkippingDate, oneTimeDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        dogId, reminderAction, reminderCustomActionName, reminderType, reminderIsEnabled, reminderExecutionBasis, reminderExecutionDate, reminderLastModified,
        false, 0, 0,
        countdownExecutionInterval, 0,
        weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, false, undefined,
        monthlyDay, monthlyHour, monthlyMinute, false, undefined,
        oneTimeDate,
      ],
    );

    // ...reminder must come first otherwise its placeholder reminderId will override the real one
    // was able to successfully create reminder, return the provided reminder with its added to the body
    return {
      ...reminder,
      reminderId: result.insertId,
    };
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
   * Queries the database to create a multiple reminders. If the query is successful, then returns the reminders with their created reminderIds added to them.
 *  If a problem is encountered, creates and throws custom error
   */
const createRemindersQuery = async (req, reminders) => {
  const dogId = req.params.dogId; // required
  const remindersArray = formatArray(reminders); // required
  const createdReminders = [];

  if (areAllDefined(dogId, remindersArray) === false) {
    throw new ValidationError('dogId or reminders missing', 'ER_VALUES_MISSING');
  }

  for (let i = 0; i < remindersArray.length; i += 1) {
    // retrieve the original provided body AND the created id
    const createdReminder = await createReminderQuery(req, remindersArray[i]);
    createdReminders.push(createdReminder);
  }
  // everything was successful so we return the created reminders
  return createdReminders;
};

module.exports = { createReminderQuery, createRemindersQuery };
