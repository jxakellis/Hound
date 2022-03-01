const { queryPromise } = require('../../utils/queryPromise');
const { formatNumber } = require('../../utils/validateFormat');

/* KNOWN:
- reminderId defined
*/

const createCountdownComponents = async (req, reminderId) => {
  const countdownExecutionInterval = formatNumber(req.body.countdownExecutionInterval);
  const countdownIntervalElapsed = formatNumber(req.body.countdownIntervalElapsed);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  await queryPromise(
    req,
    'INSERT INTO reminderCountdownComponents(reminderId, countdownExecutionInterval, countdownIntervalElapsed) VALUES (?,?,?)',
    [reminderId, countdownExecutionInterval, countdownIntervalElapsed],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateCountdownComponents = async (req, reminderId) => {
  const countdownExecutionInterval = formatNumber(req.body.countdownExecutionInterval);
  const countdownIntervalElapsed = formatNumber(req.body.countdownIntervalElapsed);

  try {
    // If this succeeds: Reminder was not present in the countdown table and the timingStyle was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderCountdownComponents(reminderId, countdownExecutionInterval, countdownIntervalElapsed) VALUES (?,?,?)',
      [reminderId, countdownExecutionInterval, countdownIntervalElapsed],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the countdown table, timingStyle didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    await queryPromise(
      req,
      'UPDATE reminderCountdownComponents SET countdownExecutionInterval = ?, countdownIntervalElapsed = ? WHERE reminderId = ?',
      [countdownExecutionInterval, countdownIntervalElapsed, reminderId],
    );
  }
};

module.exports = { createCountdownComponents, updateCountdownComponents };
