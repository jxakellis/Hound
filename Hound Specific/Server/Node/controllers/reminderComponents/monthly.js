const { queryPromise } = require('../../utils/queryPromise');
const { formatDate, formatBoolean, formatNumber } = require('../../utils/validateFormat');

const createMonthlyComponents = async (req, reminder) => {
  const monthlyHour = formatNumber(reminder.monthlyHour);
  const monthlyMinute = formatNumber(reminder.monthlyMinute);
  const dayOfMonth = formatNumber(reminder.dayOfMonth);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  // Newly created monthly reminder cant be monthlyIsSkipping, so no need for skip data
  await queryPromise(
    req,
    'INSERT INTO reminderMonthlyComponents(reminderId, monthlyHour, monthlyMinute, dayOfMonth) VALUES (?,?,?,?)',
    [reminder.reminderId, monthlyHour, monthlyMinute, dayOfMonth],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateMonthlyComponents = async (req, reminder) => {
  const monthlyHour = formatNumber(reminder.monthlyHour);
  const monthlyMinute = formatNumber(reminder.monthlyMinute);
  const dayOfMonth = formatNumber(reminder.dayOfMonth);
  const monthlyIsSkipping = formatBoolean(reminder.monthlyIsSkipping);
  const monthlyIsSkippingDate = formatDate(reminder.monthlyIsSkippingDate);

  try {
    // If this succeeds: Reminder was not present in the monthly table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderMonthlyComponents(reminderId, monthlyHour, monthlyMinute, dayOfMonth) VALUES (?,?,?,?)',
      [reminder.reminderId, monthlyHour, monthlyMinute, dayOfMonth],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the monthly table, reminderType didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    if (monthlyIsSkipping === true) {
      await queryPromise(
        req,
        'UPDATE reminderMonthlyComponents SET monthlyHour = ?, monthlyMinute = ?, dayOfMonth = ?, monthlyIsSkipping = ?, monthlyIsSkippingDate = ? WHERE reminderId = ?',
        [monthlyHour, monthlyMinute, dayOfMonth, monthlyIsSkipping, monthlyIsSkippingDate, reminder.reminderId],
      );
    }
    else {
      await queryPromise(
        req,
        'UPDATE reminderMonthlyComponents SET monthlyHour = ?, monthlyMinute = ?, dayOfMonth = ?, monthlyIsSkipping = ?  WHERE reminderId = ?',
        [monthlyHour, monthlyMinute, dayOfMonth, monthlyIsSkipping, reminder.reminderId],
      );
    }
  }
};

module.exports = { createMonthlyComponents, updateMonthlyComponents };
