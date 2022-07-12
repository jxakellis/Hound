const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatNumber, formatDate, formatBoolean, formatArray,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a update reminder. If the query is successful, then returns the provided reminder
 *  If a problem is encountered, creates and throws custom error
 */
const updateReminderForReminder = async (req, reminder) => {
  // check that we have a reminder to update in the first place
  if (areAllDefined(reminder) === false) {
    throw new ValidationError('reminder missing', global.constant.error.value.MISSING);
  }

  // general reminder components
  const dogId = req.params.dogId;
  const reminderId = reminder.reminderId;
  const { reminderAction, reminderCustomActionName, reminderType } = reminder;
  const reminderIsEnabled = formatBoolean(reminder.reminderIsEnabled);
  const reminderExecutionBasis = formatDate(reminder.reminderExecutionBasis);
  const reminderExecutionDate = formatDate(reminder.reminderExecutionDate);
  const dogLastModified = new Date();
  const reminderLastModified = dogLastModified;

  // snooze components
  const snoozeIsEnabled = formatBoolean(reminder.snoozeIsEnabled);
  const snoozeExecutionInterval = formatNumber(reminder.snoozeExecutionInterval);
  const snoozeIntervalElapsed = formatNumber(reminder.snoozeIntervalElapsed);

  // countdown components
  const countdownExecutionInterval = formatNumber(reminder.countdownExecutionInterval);
  const countdownIntervalElapsed = formatNumber(reminder.countdownIntervalElapsed);

  // weekly components
  const weeklyHour = formatNumber(reminder.weeklyHour);
  const weeklyMinute = formatNumber(reminder.weeklyMinute);
  const weeklySunday = formatBoolean(reminder.weeklySunday);
  const weeklyMonday = formatBoolean(reminder.weeklyMonday);
  const weeklyTuesday = formatBoolean(reminder.weeklyTuesday);
  const weeklyWednesday = formatBoolean(reminder.weeklyWednesday);
  const weeklyThursday = formatBoolean(reminder.weeklyThursday);
  const weeklyFriday = formatBoolean(reminder.weeklyFriday);
  const weeklySaturday = formatBoolean(reminder.weeklySaturday);
  const weeklyIsSkipping = formatBoolean(reminder.weeklyIsSkipping);
  const weeklyIsSkippingDate = formatDate(reminder.weeklyIsSkippingDate);

  // monthly components
  const monthlyDay = formatNumber(reminder.monthlyDay);
  const monthlyHour = formatNumber(reminder.monthlyHour);
  const monthlyMinute = formatNumber(reminder.monthlyMinute);
  const monthlyIsSkipping = formatBoolean(reminder.monthlyIsSkipping);
  const monthlyIsSkippingDate = formatDate(reminder.monthlyIsSkippingDate);

  // one time components
  const oneTimeDate = formatDate(reminder.oneTimeDate);

  // check to see that necessary generic reminder components are present
  if (areAllDefined(reminderId, reminderAction, reminderType, reminderIsEnabled, reminderExecutionBasis) === false) {
    throw new ValidationError('reminderId, reminderAction, reminderType, reminderIsEnabled, or reminderExecutionBasis missing', global.constant.error.value.MISSING);
  }
  else if (reminderType !== 'countdown' && reminderType !== 'weekly' && reminderType !== 'monthly' && reminderType !== 'oneTime') {
    throw new ValidationError('reminderType invalid', global.constant.error.value.INVALID);
  }
  // snooze
  else if (areAllDefined(snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed) === false) {
    throw new ValidationError('snoozeIsEnabled, snoozeExecutionInterval, or snoozeIntervalElapsed missing', global.constant.error.value.MISSING);
  }
  // countdown
  else if (areAllDefined(countdownExecutionInterval, countdownIntervalElapsed) === false) {
    throw new ValidationError('countdownExecutionInterval or countdownIntervalElapsed missing', global.constant.error.value.MISSING);
  }
  // weekly
  else if (areAllDefined(weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, weeklyIsSkipping) === false) {
    throw new ValidationError('weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, or weeklyIsSkipping missing', global.constant.error.value.MISSING);
  }
  else if (weeklyIsSkipping === true && areAllDefined(weeklyIsSkippingDate) === false) {
    throw new ValidationError('weeklyIsSkippingDate missing', global.constant.error.value.MISSING);
  }
  // monthly
  else if (areAllDefined(monthlyDay, monthlyHour, monthlyMinute, monthlyIsSkipping) === false) {
    throw new ValidationError('monthlyDay, monthlyHour, monthlyMinute, or monthlyIsSkipping missing', global.constant.error.value.MISSING);
  }
  else if (monthlyIsSkipping === true && areAllDefined(monthlyIsSkippingDate) === false) {
    throw new ValidationError('monthlyIsSkippingDate missing', global.constant.error.value.MISSING);
  }
  // oneTime
  else if (areAllDefined(oneTimeDate) === false) {
    throw new ValidationError('oneTimeDate missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    req,
    'UPDATE dogReminders SET reminderAction = ?, reminderCustomActionName = ?, reminderType = ?, reminderIsEnabled = ?, reminderExecutionBasis = ?, reminderExecutionDate = ?, reminderLastModified = ?, snoozeIsEnabled = ?, snoozeExecutionInterval = ?, snoozeIntervalElapsed = ?, countdownExecutionInterval = ?, countdownIntervalElapsed = ?, weeklyHour = ?, weeklyMinute = ?, weeklySunday = ?, weeklyMonday = ?, weeklyTuesday = ?, weeklyWednesday = ?, weeklyThursday = ?, weeklyFriday = ?, weeklySaturday = ?, weeklyIsSkipping = ?, weeklyIsSkippingDate = ?, monthlyDay = ?, monthlyHour = ?, monthlyMinute = ?, monthlyIsSkipping = ?, monthlyIsSkippingDate = ?, oneTimeDate = ? WHERE reminderId = ?',
    [
      reminderAction, reminderCustomActionName, reminderType, reminderIsEnabled, reminderExecutionBasis, reminderExecutionDate, reminderLastModified,
      snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed,
      countdownExecutionInterval, countdownIntervalElapsed,
      weeklyHour, weeklyMinute, weeklySunday, weeklyMonday, weeklyTuesday, weeklyWednesday, weeklyThursday, weeklyFriday, weeklySaturday, weeklyIsSkipping, weeklyIsSkippingDate,
      monthlyDay, monthlyHour, monthlyMinute, monthlyIsSkipping, monthlyIsSkippingDate,
      oneTimeDate,
      reminderId,
    ],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );

  return [reminder];
};

/**
 *  Queries the database to update multiple reminders. If the query is successful, then return the provided reminders
 *  If a problem is encountered, creates and throws custom error
 */
const updateRemindersForReminders = async (req, reminders) => {
  const remindersArray = formatArray(reminders);

  if (areAllDefined(remindersArray) === false) {
    throw new ValidationError('reminders missing', global.constant.error.value.MISSING);
  }

  for (let i = 0; i < remindersArray.length; i += 1) {
    await updateReminderForReminder(req, remindersArray[i]);
  }

  return remindersArray;
};

module.exports = { updateReminderForReminder, updateRemindersForReminders };