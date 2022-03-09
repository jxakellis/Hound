const { queryPromise } = require('../../utils/queryPromise');

/**
 * Returns the reminder for the dogId. Errors not handled
 * @param {*} req
 * @param {*} reminderId
 * @returns
 */
const queryReminder = async (req, reminderId) => {
// left joins dogReminders and component tables so that a reminder has all of its components attached
  // tables where the dogReminder isn't present (i.e. its reminderType is different) will just append lots of null values to result
  let result = await queryPromise(
    req,
    'SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId WHERE dogReminders.reminderId = ?',
    [reminderId],
  );

  // there will be only one result so just take first item in array
  result = result[0];

  // because of all the null values from left join, since only one component table (for the corresponding reminderType) will have the reminder, we need to remve
  // eslint-disable-next-line no-restricted-syntax
  for (const [key, value] of Object.entries(result)) {
    // checks for null json values, if json value is null then removes the key
    if (value === null) {
      delete result[key];
    }
  }

  return result;
};

/**
 * Returns an array of all the reminders for the dogId. Errors not handled
 * @param {*} req
 * @param {*} dogId
 * @returns
 */
const queryReminders = async (req, dogId) => {
// get all reminders for the dogId, then left join to all reminder components table so each reminder has compoents attached
  const result = await queryPromise(
    req,
    'SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId WHERE dogReminders.dogId = ?',
    [dogId],
  );

  if (result.length === 0) {
    return result;
  }
  else {
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
};

module.exports = { queryReminder, queryReminders };
