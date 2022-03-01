const { queryPromise } = require('../../utils/queryPromise');
const { formatDate, formatBoolean, formatNumber } = require('../../utils/validateFormat');

const createWeeklyComponents = async (req, reminderId) => {
  const hour = formatNumber(req.body.hour);
  const minute = formatNumber(req.body.minute);
  const sunday = formatBoolean(req.body.sunday);
  const monday = formatBoolean(req.body.monday);
  const tuesday = formatBoolean(req.body.tuesday);
  const wednesday = formatBoolean(req.body.wednesday);
  const thursday = formatBoolean(req.body.thursday);
  const friday = formatBoolean(req.body.friday);
  const saturday = formatBoolean(req.body.saturday);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  // Newly created weekly reminder cant be skipping, so no need for skip data
  await queryPromise(
    req,
    'INSERT INTO reminderWeeklyComponents(reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday) VALUES (?,?,?,?,?,?,?,?,?,?)',
    [reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateWeeklyComponents = async (req, reminderId) => {
  const hour = formatNumber(req.body.hour);
  const minute = formatNumber(req.body.minute);
  const sunday = formatBoolean(req.body.sunday);
  const monday = formatBoolean(req.body.monday);
  const tuesday = formatBoolean(req.body.tuesday);
  const wednesday = formatBoolean(req.body.wednesday);
  const thursday = formatBoolean(req.body.thursday);
  const friday = formatBoolean(req.body.friday);
  const saturday = formatBoolean(req.body.saturday);
  const skipping = formatBoolean(req.body.skipping);
  const skipDate = formatDate(req.body.skipDate);

  try {
    // If this succeeds: Reminder was not present in the weekly table and the timingStyle was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderWeeklyComponents(reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday) VALUES (?,?,?,?,?,?,?,?,?,?)',
      [reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the weekly table, timingStyle didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    if (skipping === true) {
      await queryPromise(
        req,
        'UPDATE reminderWeeklyComponents SET hour = ?, minute = ?, sunday = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, skipping = ?, skipDate = ? WHERE reminderId = ?',
        [hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, skipping, skipDate, reminderId],
      );
    }
    else {
      await queryPromise(
        req,
        'UPDATE reminderWeeklyComponents SET hour = ?, minute = ?, sunday = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, skipping = ? WHERE reminderId = ?',
        [hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, skipping, reminderId],
      );
    }
  }
};

module.exports = { createWeeklyComponents, updateWeeklyComponents };
