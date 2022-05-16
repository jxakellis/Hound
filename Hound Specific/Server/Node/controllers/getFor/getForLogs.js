const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/validation/validateFormat');

/**
 *  If the query is successful, returns the log for the dogId.
 *  If a problem is encountered, creates and throws custom error
*/
const getLogQuery = async (req, logId) => {
  // verify that a logId was passed
  if (areAllDefined(logId) === false) {
    throw new ValidationError('logId missing', 'ER_VALUES_MISSING');
  }
  try {
    // only select the relevant information to save on data
    const result = await queryPromise(
      req,
      'SELECT logId, dogId, userId, logDate, logNote, logAction, logCustomActionName FROM dogLogs WHERE logId = ? LIMIT 1',
      [logId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  If the query is successful, returns an array of all the logs for the dogId. Errors not handled
 *  If a problem is encountered, creates and throws custom error
 */
const getLogsQuery = async (req, dogId) => {
  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }
  try {
    // only select the relevant information to save on data
    const result = await queryPromise(
      req,
      'SELECT logId, dogId, userId, logDate, logNote, logAction, logCustomActionName FROM dogLogs WHERE dogId = ? ORDER BY logDate DESC LIMIT 1000',
      [dogId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getLogQuery, getLogsQuery };
