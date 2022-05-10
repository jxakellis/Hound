const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatDate, formatBoolean, formatNumber, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

const createMonthlyComponents = async (req, reminder) => {
  const monthlyHour = formatNumber(reminder.monthlyHour);
  const monthlyMinute = formatNumber(reminder.monthlyMinute);
  const monthlyDay = formatNumber(reminder.monthlyDay);

  if (areAllDefined(reminder.reminderId, monthlyHour, monthlyMinute, monthlyDay) === false) {
    throw new ValidationError('reminderId, monthlyHour, monthlyMinute, or monthlyDay missing', 'ER_VALUES_MISSING');
  }

  // Newly created monthly reminder cant be monthlyIsSkipping, so no need for skip data
  await queryPromise(
    req,
    'INSERT INTO reminderMonthlyComponents(reminderId, monthlyHour, monthlyMinute, monthlyDay, monthlyIsSkipping, monthlyIsSkippingDate) VALUES (?,?,?,?,?,?)',
    [reminder.reminderId, monthlyHour, monthlyMinute, monthlyDay, false, undefined],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateMonthlyComponents = async (req, reminder) => {
  const monthlyHour = formatNumber(reminder.monthlyHour);
  const monthlyMinute = formatNumber(reminder.monthlyMinute);
  const monthlyDay = formatNumber(reminder.monthlyDay);
  const monthlyIsSkipping = formatBoolean(reminder.monthlyIsSkipping);
  const monthlyIsSkippingDate = formatDate(reminder.monthlyIsSkippingDate);

  if (areAllDefined(reminder.reminderId, monthlyHour, monthlyMinute, monthlyDay, monthlyIsSkipping) === false) {
    throw new ValidationError('reminderId, monthlyHour, monthlyMinute, monthlyDay, or monthlyIsSkipping missing', 'ER_VALUES_MISSING');
  }
  else if (monthlyIsSkipping === true && areAllDefined(monthlyIsSkippingDate) === false) {
    throw new ValidationError('monthlyIsSkippingDate missing', 'ER_VALUES_MISSING');
  }

  try {
    // If this succeeds: Reminder was not present in the monthly table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderMonthlyComponents(reminderId, monthlyHour, monthlyMinute, monthlyDay, monthlyIsSkipping, monthlyIsSkippingDate) VALUES (?,?,?,?,?,?)',
      [reminder.reminderId, monthlyHour, monthlyMinute, monthlyDay, false, undefined],
    );
  }
  catch (error) {
    // If this succeeds: Reminder was present in the monthly table, reminderType didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    await queryPromise(
      req,
      'UPDATE reminderMonthlyComponents SET monthlyHour = ?, monthlyMinute = ?, monthlyDay = ?, monthlyIsSkipping = ?, monthlyIsSkippingDate = ? WHERE reminderId = ?',
      [monthlyHour, monthlyMinute, monthlyDay, monthlyIsSkipping, monthlyIsSkippingDate, reminder.reminderId],
    );
  }
};

module.exports = { createMonthlyComponents, updateMonthlyComponents };
