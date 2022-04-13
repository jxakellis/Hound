const { queryPromise } = require('../../utils/database/queryPromise');
const { formatDate } = require('../../utils/database/validateFormat');

const createOneTimeComponents = async (req, reminder) => {
  const oneTimeDate = formatDate(reminder.oneTimeDate);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  await queryPromise(
    req,
    'INSERT INTO reminderOneTimeComponents(reminderId, oneTimeDate) VALUES (?,?)',
    [reminder.reminderId, oneTimeDate],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateOneTimeComponents = async (req, reminder) => {
  const oneTimeDate = formatDate(reminder.oneTimeDate);

  try {
    // If this succeeds: Reminder was not present in the weekly table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderOneTimeComponents(reminderId, oneTimeDate) VALUES (?,?)',
      [reminder.reminderId, oneTimeDate],
    );
    return;
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
