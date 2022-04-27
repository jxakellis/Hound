const { queryPromise } = require('../../utils/database/queryPromise');
const { formatNumber } = require('../../utils/database/validateFormat');

/* KNOWN:
- reminderId defined
*/

const createCountdownComponents = async (req, reminder) => {
  const countdownExecutionInterval = formatNumber(reminder.countdownExecutionInterval);
  const countdownIntervalElapsed = formatNumber(reminder.countdownIntervalElapsed);

  // TO DO add check that all components are defined (or throw validation error)

  await queryPromise(
    req,
    'INSERT INTO reminderCountdownComponents(reminderId, countdownExecutionInterval, countdownIntervalElapsed) VALUES (?,?,?)',
    [reminder.reminderId, countdownExecutionInterval, countdownIntervalElapsed],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateCountdownComponents = async (req, reminder) => {
  const countdownExecutionInterval = formatNumber(reminder.countdownExecutionInterval);
  const countdownIntervalElapsed = formatNumber(reminder.countdownIntervalElapsed);

  // TO DO add check that all components are defined (or throw validation error)

  try {
    // If this succeeds: Reminder was not present in the countdown table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderCountdownComponents(reminderId, countdownExecutionInterval, countdownIntervalElapsed) VALUES (?,?,?)',
      [reminder.reminderId, countdownExecutionInterval, countdownIntervalElapsed],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the countdown table, reminderType didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    await queryPromise(
      req,
      'UPDATE reminderCountdownComponents SET countdownExecutionInterval = ?, countdownIntervalElapsed = ? WHERE reminderId = ?',
      [countdownExecutionInterval, countdownIntervalElapsed, reminder.reminderId],
    );
  }
};

module.exports = { createCountdownComponents, updateCountdownComponents };
