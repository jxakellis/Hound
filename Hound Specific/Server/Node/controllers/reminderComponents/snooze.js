const { queryPromise } = require('../../utils/database/queryPromise');
const { formatBoolean, formatNumber } = require('../../utils/database/validateFormat');

const createSnoozeComponents = async (req, reminder) => {
  const snoozeIsEnabled = formatBoolean(reminder.snoozeIsEnabled);

  // Only insert components if the reminder is snoozing, otherwise there is no need for them
  // Errors intentionally uncaught so they are passed to invocation in reminders
  if (snoozeIsEnabled === true) {
    const snoozeExecutionInterval = formatNumber(reminder.snoozeExecutionInterval);
    const snoozeIntervalElapsed = formatNumber(reminder.snoozeIntervalElapsed);
    await queryPromise(
      req,
      'INSERT INTO reminderSnoozeComponents(reminderId, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed) VALUES (?,?,?,?)',
      [reminder.reminderId, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed],
    );
  }
  else {
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',
      [reminder.reminderId],
    );
  }
};
/**
 * Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
 */
const updateSnoozeComponents = async (req, reminder) => {
  const snoozeIsEnabled = formatBoolean(reminder.snoozeIsEnabled);

  // if reminder is going into snooze mode then we update/insert the needed components
  if (snoozeIsEnabled === true) {
    const snoozeExecutionInterval = formatNumber(reminder.snoozeExecutionInterval);
    const snoozeIntervalElapsed = formatNumber(reminder.snoozeIntervalElapsed);
    try {
      // If this succeeds: Reminder was not present in the snooze table and the reminder was snoozed.
      // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
      await queryPromise(
        req,
        'INSERT INTO reminderSnoozeComponents(reminderId, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed) VALUES (?,?,?,?)',
        [reminder.reminderId, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed],
      );
      return;
    }
    catch (error) {
      // If this succeeds: Reminder was present in the snooze table, reminderType didn't change, and the components were successfully updated
      // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
      await queryPromise(
        req,
        'UPDATE reminderSnoozeComponents SET snoozeIsEnabled = ?, snoozeExecutionInterval = ?, snoozeIntervalElapsed = ? WHERE reminderId = ?',
        [snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed, reminder.reminderId],
      );
    }
  }
  // if the reminder is leaving snooze mode (snoozeIsEnabled === false) then we delete the components
  else {
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',
      [reminder.reminderId],
    );
  }
};

module.exports = { createSnoozeComponents, updateSnoozeComponents };
