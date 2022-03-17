const { queryPromise } = require('../../utils/queryPromise');
const { formatBoolean } = require('../../utils/validateFormat');
const { queryLogs } = require('./queryForLogs');
const { queryReminders } = require('./queryForReminders');

/**
 * Returns the dog for the dogId. Errors not handled
 * @param {*} req
 * @param {*} dogId
 * @returns
 */
const queryDog = async (req, dogId) => {
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
      const remindersResult = await queryReminders(req, dogId);

      result[0].reminders = remindersResult;
    }
    if (queryForLogs === true) {
      const logsResult = await queryLogs(req, dogId);

      result[0].logs = logsResult;
    }
    return result;
  }
};

/**
 * Returns an array of all the dogs for the userId. Errors not handled
 * @param {*} req
 * @param {*} dogId
 * @returns
 */
const queryDogs = async (req, userId) => {
  const result = await queryPromise(
    req,
    'SELECT * FROM dogs WHERE dogs.userId = ?',
    [userId],
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
        const reminderResult = await queryReminders(req, result[i].dogId);
        result[i].reminders = reminderResult;
      }
    }
    if (queryForLogs === true) {
      for (let i = 0; i < result.length; i += 1) {
        const logResult = await queryLogs(req, result[i].dogId);
        result[i].logs = logResult;
      }
    }
    return result;
  }
};

module.exports = { queryDog, queryDogs };
