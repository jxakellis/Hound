const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/database/queryPromise');
const { deleteLogsQuery } = require('./deleteForLogs');
const { deleteReminderQuery } = require('./deleteForReminders');

/**
 *  Queries the database to delete a dog and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteDogQuery = async (req, userId, familyId, dogId) => {
  let reminderIds;

  // find reminderIds of reminders that need deleted
  try {
    reminderIds = await queryPromise(
      req,
      'SELECT reminderId FROM dogReminders WHERE dogId = ?',

      [dogId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // deletes all reminders since we found reminderIds
  for (let i = 0; i < reminderIds.length; i += 1) {
    await deleteReminderQuery(req, userId, familyId, reminderIds[i].reminderId);
  }

  // deletes all logs
  await deleteLogsQuery(req, dogId);

  try {
    // deletes dog
    await queryPromise(req, 'DELETE FROM dogs WHERE dogId = ?', [dogId]);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 * Queries the database to delete all dog and everything nested under them. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteDogsQuery = async (req, userId, familyId) => {
  let dogIds;

  // attempt to find all dogIds
  try {
    dogIds = await queryPromise(req, 'SELECT dogId FROM dogs WHERE familyId = ?', [familyId]);
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // delete all the dogs
  for (let i = 0; i < dogIds.length; i += 1) {
    await deleteDogQuery(req, userId, familyId, dogIds[i].dogId);
  }
};

module.exports = { deleteDogQuery, deleteDogsQuery };
