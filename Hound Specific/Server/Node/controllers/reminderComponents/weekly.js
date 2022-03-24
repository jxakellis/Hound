const { queryPromise } = require('../../utils/queryPromise');
const { formatDate, formatBoolean, formatNumber } = require('../../utils/validateFormat');

const createWeeklyComponents = async (req, reminderId) => {
  const weeklyHour = formatNumber(req.body.weeklyHour);
  const weeklyMinute = formatNumber(req.body.weeklyMinute);
  const sunday = formatBoolean(req.body.sunday);
  const monday = formatBoolean(req.body.monday);
  const tuesday = formatBoolean(req.body.tuesday);
  const wednesday = formatBoolean(req.body.wednesday);
  const thursday = formatBoolean(req.body.thursday);
  const friday = formatBoolean(req.body.friday);
  const saturday = formatBoolean(req.body.saturday);

  // Errors intentionally uncaught so they are passed to invocation in reminders
  // Newly created weekly reminder cant be weeklyIsSkipping, so no need for skip data
  await queryPromise(
    req,
    'INSERT INTO reminderWeeklyComponents(reminderId, weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday) VALUES (?,?,?,?,?,?,?,?,?,?)',
    [reminderId, weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday],
  );
};

// Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateWeeklyComponents = async (req, reminderId) => {
  const weeklyHour = formatNumber(req.body.weeklyHour);
  const weeklyMinute = formatNumber(req.body.weeklyMinute);
  const sunday = formatBoolean(req.body.sunday);
  const monday = formatBoolean(req.body.monday);
  const tuesday = formatBoolean(req.body.tuesday);
  const wednesday = formatBoolean(req.body.wednesday);
  const thursday = formatBoolean(req.body.thursday);
  const friday = formatBoolean(req.body.friday);
  const saturday = formatBoolean(req.body.saturday);
  const weeklyIsSkipping = formatBoolean(req.body.weeklyIsSkipping);
  const weeklySkipDate = formatDate(req.body.weeklySkipDate);

  try {
    // If this succeeds: Reminder was not present in the weekly table and the reminderType was changed. The old components will be deleted from the other table by reminders
    // If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
    await queryPromise(
      req,
      'INSERT INTO reminderWeeklyComponents(reminderId, weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday) VALUES (?,?,?,?,?,?,?,?,?,?)',
      [reminderId, weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday],
    );
    return;
  }
  catch (error) {
    // If this succeeds: Reminder was present in the weekly table, reminderType didn't change, and the components were successfully updated
    // If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
    if (weeklyIsSkipping === true) {
      await queryPromise(
        req,
        'UPDATE reminderWeeklyComponents SET weeklyHour = ?, weeklyMinute = ?, sunday = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, weeklyIsSkipping = ?, weeklySkipDate = ? WHERE reminderId = ?',
        [weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, weeklyIsSkipping, weeklySkipDate, reminderId],
      );
    }
    else {
      await queryPromise(
        req,
        'UPDATE reminderWeeklyComponents SET weeklyHour = ?, weeklyMinute = ?, sunday = ?, monday = ?, tuesday = ?, wednesday = ?, thursday = ?, friday = ?, saturday = ?, weeklyIsSkipping = ? WHERE reminderId = ?',
        [weeklyHour, weeklyMinute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, weeklyIsSkipping, reminderId],
      );
    }
  }
};

module.exports = { createWeeklyComponents, updateWeeklyComponents };
