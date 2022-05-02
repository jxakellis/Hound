const DatabaseError = require('../../main/tools/errors/databaseError');
const { queryPromise } = require('../../main/tools/database/queryPromise');

/**
 * Returns the log for the dogId. Errors not handled
*/
const getLogQuery = async (req, logId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT * FROM dogLogs WHERE logId = ? LIMIT 1',
      [logId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 * Returns an array of all the logs for the dogId. Errors not handled
 */
const getLogsQuery = async (req, dogId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT * FROM dogLogs WHERE dogId = ? ORDER BY logDate DESC LIMIT 1000',
      [dogId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getLogQuery, getLogsQuery };
