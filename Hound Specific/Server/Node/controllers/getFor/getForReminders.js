const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/validation/validateFormat');

const dogRemindersSelect = 'dogReminders.reminderId, dogReminders.reminderAction, dogReminders.reminderCustomActionName, dogReminders.reminderType, dogReminders.reminderExecutionBasis, dogReminders.reminderIsEnabled, dogReminders.reminderExecutionDate';

const reminderSnoozeComponentsSelect = 'reminderSnoozeComponents.snoozeExecutionInterval, reminderSnoozeComponents.snoozeIntervalElapsed, reminderSnoozeComponents.snoozeIsEnabled';
const reminderSnoozeComponentsLeftJoin = 'LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId';

const reminderCountdownComponentsSelect = 'reminderCountdownComponents.countdownExecutionInterval, reminderCountdownComponents.countdownIntervalElapsed';
const reminderCountdownComponentsLeftJoin = 'LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId';

const reminderWeeklyComponentsSelect = 'reminderWeeklyComponents.weeklyHour, reminderWeeklyComponents.weeklyMinute, reminderWeeklyComponents.weeklyIsSkipping, reminderWeeklyComponents.weeklyIsSkippingDate, reminderWeeklyComponents.sunday, reminderWeeklyComponents.monday, reminderWeeklyComponents.tuesday, reminderWeeklyComponents.wednesday, reminderWeeklyComponents.thursday, reminderWeeklyComponents.friday, reminderWeeklyComponents.saturday';
const reminderWeeklyComponentsLeftJoin = 'LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId';

const reminderMonthlyComponentsSelect = 'reminderMonthlyComponents.monthlyHour, reminderMonthlyComponents.monthlyMinute, reminderMonthlyComponents.monthlyIsSkipping, reminderMonthlyComponents.monthlyIsSkippingDate, reminderMonthlyComponents.monthlyDay';
const reminderMonthlyComponentsLeftJoin = 'LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId';

const reminderOneTimeComponentsSelect = 'reminderOneTimeComponents.oneTimeDate';
const reminderOneTimeComponentsLeftJoin = 'LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId';

/**
 *  If the query is successful, returns the reminder for the reminderId.
 *  If a problem is encountered, creates and throws custom error
 */
const getReminderQuery = async (req, reminderId) => {
  if (areAllDefined(reminderId) === false) {
    throw new ValidationError('reminderId missing', 'ER_VALUES_MISSING');
  }

  let result;
  try {
    // find reminder that matches the id
    result = await queryPromise(
      req,
      `SELECT ${dogRemindersSelect}, ${reminderSnoozeComponentsSelect}, ${reminderCountdownComponentsSelect}, ${reminderWeeklyComponentsSelect}, ${reminderMonthlyComponentsSelect}, ${reminderOneTimeComponentsSelect} FROM dogReminders ${reminderSnoozeComponentsLeftJoin} ${reminderCountdownComponentsLeftJoin} ${reminderWeeklyComponentsLeftJoin} ${reminderMonthlyComponentsLeftJoin} ${reminderOneTimeComponentsLeftJoin} WHERE dogReminders.reminderId = ? LIMIT 1`,
      [reminderId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // iterate through all the reminders returned
  for (let i = 0; i < result.length; i += 1) {
    // because of all the null values from left join, since only one component table (for the corresponding reminderType) will have the reminder, we need to remve
    // eslint-disable-next-line no-restricted-syntax
    for (const [key, value] of Object.entries(result[i])) {
      // checks for null json values, if json value is null then removes the key
      if (value === null) {
        delete result[i][key];
      }
    }
  }

  return result;
};

/**
 *  If the query is successful, returns an array of all the reminders for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const getRemindersQuery = async (req, dogId) => {
  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }

  try {
    // find reminder that matches the dogId
    const result = await queryPromise(
      req,
      `SELECT ${dogRemindersSelect}, ${reminderSnoozeComponentsSelect}, ${reminderCountdownComponentsSelect}, ${reminderWeeklyComponentsSelect}, ${reminderMonthlyComponentsSelect}, ${reminderOneTimeComponentsSelect} FROM dogReminders ${reminderSnoozeComponentsLeftJoin} ${reminderCountdownComponentsLeftJoin} ${reminderWeeklyComponentsLeftJoin} ${reminderMonthlyComponentsLeftJoin} ${reminderOneTimeComponentsLeftJoin} WHERE dogReminders.dogId = ? ORDER BY reminderId DESC LIMIT 1000`,
      [dogId],
    );

    // iterate through all the reminders returned
    for (let i = 0; i < result.length; i += 1) {
      // because of all the null values from left join, since only one component table (for the corresponding reminderType) will have the reminder, we need to remve
      // eslint-disable-next-line no-restricted-syntax
      for (const [key, value] of Object.entries(result[i])) {
        // checks for null json values, if json value is null then removes the key
        if (value === null) {
          delete result[i][key];
        }
      }
    }

    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getReminderQuery, getRemindersQuery };
