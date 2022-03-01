const { queryPromise } = require('../../utils/queryPromise');
const { formatDate, formatBoolean, formatNumber } = require('../../utils/validateFormat');

const createMonthlyComponents = async (req, reminderId) => {
  const hour = formatNumber(req.body.hour);
  const minute = formatNumber(req.body.minute);
  const dayOfMonth = formatNumber(req.body.dayOfMonth);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  // Newly created monthly reminder cant be skipping, so no need for skip data
  await queryPromise(
    req,
    'INSERT INTO reminderMonthlyComponents(reminderId, hour, minute, dayOfMonth) VALUES (?,?,?,?)',
    [reminderId, hour, minute, dayOfMonth],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateMonthlyComponents = async (req, reminderId) => {
  const hour = formatNumber(req.body.hour);
  const minute = formatNumber(req.body.minute);
  const dayOfMonth = formatNumber(req.body.dayOfMonth);
  const skipping = formatBoolean(req.body.skipping);
  const skipDate = formatDate(req.body.skipDate);

  try {
    // If this succeeds: Reminder was not present in the monthly table and the timingStyle was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderMonthlyComponents(reminderId, hour, minute, dayOfMonth) VALUES (?,?,?,?)',
      [reminderId, hour, minute, dayOfMonth],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the monthly table, timingStyle didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    if (skipping === true) {
      await queryPromise(
        req,
        'UPDATE reminderMonthlyComponents SET hour = ?, minute = ?, dayOfMonth = ?, skipping = ?, skipDate = ? WHERE reminderId = ?',
        [hour, minute, dayOfMonth, skipping, skipDate, reminderId],
      );
    }
    else {
      await queryPromise(
        req,
        'UPDATE reminderMonthlyComponents SET hour = ?, minute = ?, dayOfMonth = ?, skipping = ?  WHERE reminderId = ?',
        [hour, minute, dayOfMonth, skipping, reminderId],
      );
    }
  }
};

module.exports = { createMonthlyComponents, updateMonthlyComponents };
