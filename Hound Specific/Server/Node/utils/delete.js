const { queryPromise } = require('./queryPromise');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable ) dogId formatted correctly and request has sufficient permissions to use
- (if appliciable ) logId formatted correctly and request has sufficient permissions to use
*/

/**
 * Deletes a user from the users table and all other associated data from all other tables.
 */
const deleteUser = async (req, userId) => {
  const dogIds = await queryPromise(req, 'SELECT dogId FROM dogs WHERE userId = ?', [userId]);

  // deletes all dogs
  for (let i = 0; i < dogIds.length; i += 1) {
    await deleteDog(req, dogIds[i].dogId);
  }
  // delete userConfiguration
  await deleteUserConfiguration(req, userId);
  // deletes user
  await queryPromise(req, 'DELETE FROM users WHERE userId = ?', [userId]);
};

/**
 * Deletes userConfiguration from the userConfiguration table
 */
const deleteUserConfiguration = async (req, userId) => {
  // deletes user config
  await queryPromise(req, 'DELETE FROM userConfiguration WHERE userId = ?', [userId]);
};

/**
 * Deletes dog from dogs table, logs from dogLogs table, and invokes deleteReminder for all reminderIds to handle removing reminders
 */
const deleteDog = async (req, dogId) => {
  const reminderIds = await queryPromise(
    req,
    'SELECT reminderId FROM dogReminders WHERE dogId = ?',

    [dogId],
  );

  // deletes all reminders
  for (let i = 0; i < reminderIds.length; i += 1) {
    await deleteReminder(req, reminderIds[i].reminderId);
  }
  // deletes all logs
  await queryPromise(req, 'DELETE FROM dogLogs WHERE dogId = ?', [dogId]);
  // deletes dog
  await queryPromise(req, 'DELETE FROM dogs WHERE dogId = ?', [dogId]);
};

/**
 * Deletes a log from dogLogs table
 */
const deleteLog = async (req, logId) => {
  await queryPromise(
    req,
    'DELETE FROM dogLogs WHERE logId = ?',

    [logId],
  );
};

/**
 * Deletes a reminder from dogReminder table and any component that may exist for it in any component table
 */
const deleteReminder = async (req, reminderId) => {
  // deletes all components
  await queryPromise(
    req,
    'DELETE FROM reminderCountdownComponents WHERE reminderId = ?',

    [reminderId],
  );
  await queryPromise(
    req,
    'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?',

    [reminderId],
  );
  await queryPromise(
    req,
    'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?',

    [reminderId],
  );
  await queryPromise(
    req,
    'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',

    [reminderId],
  );
  await queryPromise(
    req,
    'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?',

    [reminderId],
  );
  // deletes reminder
  await queryPromise(
    req,
    'DELETE FROM dogReminders WHERE reminderId = ?',

    [reminderId],
  );
};

/**
 * If a reminder is updated, its reminderType can be updated and switch between modes.
* This means we make an entry into a new component table and this also means the components from the old reminderType are left over in another table
* This remove the extraneous compoents
 */
const deleteLeftoverReminderComponents = async (req, reminderId, newTimingStyle) => {
  // Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

  if (newTimingStyle === 'countdown') {
    await queryPromise(
      req,
      'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?',

      [reminderId],
    );
    // updated reminder can't be snoozed so delete.
    // possible optimization here, since the reminder could be snoozed in the future we could just update isSnoozed to false instead of deleting the data
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?',

      [reminderId],
    );
  }
  else if (newTimingStyle === 'weekly') {
    await queryPromise(
      req,
      'DELETE FROM reminderCountdownComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?',

      [reminderId],
    );
  }
  else if (newTimingStyle === 'monthly') {
    await queryPromise(
      req,
      'DELETE FROM reminderCountdownComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderOneTimeComponents WHERE reminderId = ?',

      [reminderId],
    );
  }
  else if (newTimingStyle === 'oneTime') {
    await queryPromise(
      req,
      'DELETE FROM reminderCountdownComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderWeeklyComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderMonthlyComponents WHERE reminderId = ?',

      [reminderId],
    );
    await queryPromise(
      req,
      'DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',

      [reminderId],
    );
  }
  else {
    throw new Error('Invalid reminderType');
  }
};

module.exports = {
  deleteUser, deleteUserConfiguration, deleteDog, deleteLog, deleteReminder, deleteLeftoverReminderComponents,
};
