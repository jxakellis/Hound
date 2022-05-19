const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { formatBoolean, areAllDefined } = require('../../main/tools/format/formatObject');
const { getLogsQuery } = require('./getForLogs');
const { getRemindersQuery } = require('./getForReminders');

/**
 *  If the query is successful, returns the dog for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const getDogQuery = async (req, dogId) => {
  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'SELECT dogId, dogName FROM dogs WHERE dogId = ? LIMIT 1',
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
      if (queryForReminders) {
        const remindersResult = await getRemindersQuery(req, dogId);

        result[0].reminders = remindersResult;
      }
      if (queryForLogs) {
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
 *  If the query is successful, returns an array of all the dogs for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getDogsQuery = async (req, familyId) => {
  if (areAllDefined(familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'SELECT dogId, dogName FROM dogs WHERE familyId = ? ORDER BY dogId DESC LIMIT 1000',
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
      if (queryForReminders) {
        for (let i = 0; i < result.length; i += 1) {
          const reminderResult = await getRemindersQuery(req, result[i].dogId);
          result[i].reminders = reminderResult;
        }
      }
      if (queryForLogs) {
        for (let i = 0; i < result.length; i += 1) {
          const logResult = await getLogsQuery(req, result[i].dogId);
          result[i].logs = logResult;
        }
      }
      // we don't need to transmit this data
      result[0].dogLastModified = undefined;
      return result;
    }
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getDogQuery, getDogsQuery };
