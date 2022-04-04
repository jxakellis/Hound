const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/queryPromise');
const { formatBoolean } = require('../../utils/validateFormat');
const { getLogsQuery } = require('./getForLogs');
const { getRemindersQuery } = require('./getForReminders');

/**
 * Returns the dog for the dogId. Errors not handled
 */
const getDogQuery = async (req, dogId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT * FROM dogs WHERE dogs.dogId = ?',
      [dogId],
    );
    // no need to do anything else as there are no dogs
    if (result.length === 0) {
      return result;
    }
    else {
      const queryForReminders = formatBoolean(req.query.reminders);
      const queryForLogs = formatBoolean(req.query.logs);
      // if the query parameter indicates that they want the logs and the reminders too, we add them
      if (queryForReminders === true) {
        const remindersResult = await getRemindersQuery(req, dogId);

        result[0].reminders = remindersResult;
      }
      if (queryForLogs === true) {
        const logsResult = await getLogsQuery(req, dogId);

        result[0].logs = logsResult;
      }
      return result;
    }
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 * Returns an array of all the dogs for the familyId. Errors not handled
 */
const getDogsQuery = async (req, familyId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT * FROM dogs WHERE dogs.familyId = ?',
      [familyId],
    );
    // no need to do anything else as there are no dogs
    if (result.length === 0) {
      return result;
    }
    else {
      const queryForReminders = formatBoolean(req.query.reminders);
      const queryForLogs = formatBoolean(req.query.logs);
      // if the query parameter indicates that they want the logs and the reminders too, we add them.
      if (queryForReminders === true) {
        for (let i = 0; i < result.length; i += 1) {
          const reminderResult = await getRemindersQuery(req, result[i].dogId);
          result[i].reminders = reminderResult;
        }
      }
      if (queryForLogs === true) {
        for (let i = 0; i < result.length; i += 1) {
          const logResult = await getLogsQuery(req, result[i].dogId);
          result[i].logs = logResult;
        }
      }
      return result;
    }
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getDogQuery, getDogsQuery };
