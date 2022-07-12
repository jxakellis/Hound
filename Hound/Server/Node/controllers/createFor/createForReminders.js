const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatNumber, formatDate, formatBoolean, formatArray,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a single reminder. If the query is successful, then returns the reminder with created reminderId added to it.
 *  If a problem is encountered, creates and throws custom error
 */
const createReminderForDogIdReminder = async (req, dogId, reminder) => {
  if (areAllDefined(req, dogId, reminder) === false) {
    throw new ValidationError('req, dogId, or reminder missing', global.constant.error.value.MISSING);
  }

  // only retrieve enough not deleted reminders that would exceed the limit
  const reminders = await databaseQuery(
    req,
    'SELECT reminderId FROM dogReminders WHERE reminderIsDeleted = 0 AND dogId = ? LIMIT ?',
    [dogId, global.constant.limit.NUMBER_OF_REMINDERS_PER_DOG],
  );

  // make sure that the user isn't creating too many reminders
  if (reminders.length >= global.constant.limit.NUMBER_OF_REMINDERS_PER_DOG) {
    throw new ValidationError(`Dog reminder limit of ${global.constant.limit.NUMBER_OF_REMINDERS_PER_DOG} exceeded`, global.constant.error.family.limit.REMINDER_TOO_LOW);
  }

  // general reminder components
  const { reminderAction, reminderCustomActionName, reminderType } = reminder; // required
  const reminderIsEnabled = formatBoolean(reminder.reminderIsEnabled); // required
  const reminderExecutionBasis = formatDate(reminder.reminderExecutionBasis); // required
  const reminderExecutionDate = formatDate(reminder.reminderExecutionDate); // optional
  const dogLastModified = new Date();
  const reminderLastModified = dogLastModified; // manual

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
    throw new ValidationError('reminderAction, reminderType, reminderIsEnabled, or reminderExecutionBasis missing', global.constant.error.value.MISSING);
  }
  else if (reminderType !== 'countdown' && reminderType !== 'weekly' && reminderType !== 'monthly' && reminderType !== 'oneTime') {
    throw new ValidationError('reminderType invalid', global.constant.error.value.INVALID);
  }
  // no need to check snooze components as a newly created reminder can't be snoozed yet
  // no need to check for countdownIntervalElapsed as newly created reminder couldn't have elapsed time
  else if (areAllDefined(countdownExecutionInterval) === false) {
    throw new ValidationError('countdownExecutionInterval missing', global.constant.error.value.MISSING);
  }
  // no need to check weeklyIsSkipping && weeklyIsSkippingDate validity as newly created reminder can't be skipped yet
  else if (areAllDefined(weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday) === false) {
    throw new ValidationError('weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, or weeklySaturday missing', global.constant.error.value.MISSING);
  }
  // no need to check monthlyIsSkipping && monthlyIsSkippingDate validity as newly created reminder can't be skipped yet
  else if (areAllDefined(monthlyDay, monthlyHour, monthlyMinute) === false) {
    throw new ValidationError('monthlyDay, monthlyHour, or monthlyMinute missing', global.constant.error.value.MISSING);
  }
  else if (areAllDefined(oneTimeDate) === false) {
    throw new ValidationError('oneTimeDate missing', global.constant.error.value.MISSING);
  }

  const result = await databaseQuery(
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

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );

  // ...reminder must come first otherwise its placeholder reminderId will override the real one
  // was able to successfully create reminder, return the provided reminder with its added to the body
  return {
    ...reminder,
    reminderId: result.insertId,
  };
};

/**
   * Queries the database to create a multiple reminders. If the query is successful, then returns the reminders with their created reminderIds added to them.
 *  If a problem is encountered, creates and throws custom error
   */
const createRemindersForDogIdReminders = async (req, dogId, reminders) => {
  const remindersArray = formatArray(reminders); // required
  const createdReminders = [];

  if (areAllDefined(req, dogId, remindersArray) === false) {
    throw new ValidationError('req, dogId, or reminders missing', global.constant.error.value.MISSING);
  }

  for (let i = 0; i < remindersArray.length; i += 1) {
    // retrieve the original provided body AND the created id
    const createdReminder = await createReminderForDogIdReminder(req, dogId, remindersArray[i]);
    createdReminders.push(createdReminder);
  }
  // everything was successful so we return the created reminders
  return createdReminders;
};

module.exports = { createReminderForDogIdReminder, createRemindersForDogIdReminders };
