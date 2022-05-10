const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined, formatDate } = require('../../main/tools/validation/validateFormat');

const createOneTimeComponents = async (req, reminder) => {
  const oneTimeDate = formatDate(reminder.oneTimeDate);

  if (areAllDefined(reminder.reminderId, oneTimeDate) === false) {
    throw new ValidationError('reminderId or oneTimeDate missing', 'ER_VALUES_MISSING');
  }

  await queryPromise(
    req,
    'INSERT INTO reminderOneTimeComponents(reminderId, oneTimeDate) VALUES (?,?)',
    [reminder.reminderId, oneTimeDate],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateOneTimeComponents = async (req, reminder) => {
  const oneTimeDate = formatDate(reminder.oneTimeDate);

  if (areAllDefined(reminder.reminderId, oneTimeDate) === false) {
    throw new ValidationError('reminderId or oneTimeDate missing', 'ER_VALUES_MISSING');
  }

  try {
    // If this succeeds: Reminder was not present in the weekly table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderOneTimeComponents(reminderId, oneTimeDate) VALUES (?,?)',
      [reminder.reminderId, oneTimeDate],
    );
  }
  catch (error) {
    // If this succeeds: Reminder was present in the weekly table, reminderType didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    await queryPromise(
      req,
      'UPDATE reminderOneTimeComponents SET oneTimeDate = ? WHERE reminderId = ?',
      [oneTimeDate, reminder.reminderId],
    );
  }
};

module.exports = { createOneTimeComponents, updateOneTimeComponents };
