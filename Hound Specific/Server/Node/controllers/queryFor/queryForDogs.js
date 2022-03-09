const { queryPromise } = require('../../utils/queryPromise');
const { atLeastOneDefined } = require('../../utils/validateFormat');
const { queryLogs } = require('./queryForLogs');
const { queryReminders } = require('./queryForReminders');

/**
 * Returns the dog for the dogId. Errors not handled
 * @param {*} req
 * @param {*} dogId
 * @returns
 */
const queryDog = async (req, dogId) => {
  const result = await queryPromise(req, 'SELECT * FROM dogs WHERE dogs.dogId = ?', [dogId]);

  // no need to do anything else as there are no dogs
  if (result.length === 0) {
    return result;
  }
  else {
    const queryForAll = req.query.all;
    // if the query parameter indicates that they want the logs and the reminders too, we add them
    if (atLeastOneDefined(queryForAll)) {
      const logsResult = await queryLogs(req, dogId);
      const remindersResult = await queryReminders(req, dogId);

      result.logs = logsResult;
      result.reminders = remindersResult;
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
    const queryForAll = req.query.all;
    console.log(req.query);
    console.log(req.query.all);
    console.log(atLeastOneDefined(queryForAll));
    // if the query parameter indicates that they want the logs and the reminders too, we add them
    if (atLeastOneDefined(queryForAll)) {
      for (let i = 0; i < result.length; i += 1) {
        console.log(i);
        const logResult = await queryLogs(req, result[i].dogId);
        const reminderResult = await queryReminders(req, result[i].dogId);
        result[i].logs = logResult;
        result[i].reminders = reminderResult;
      }
    }
    console.log(result);
    return result;
  }
};

module.exports = { queryDog, queryDogs };
