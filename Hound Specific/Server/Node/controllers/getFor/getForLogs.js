const { queryPromise } = require('../../utils/queryPromise');

/**
 * Returns the log for the dogId. Errors not handled
*/
const getLogQuery = async (req, logId) => {
  const result = await queryPromise(req, 'SELECT * FROM dogLogs WHERE logId = ?', [logId]);
  return result;
};

/**
 * Returns an array of all the logs for the dogId. Errors not handled
 */
const getLogsQuery = async (req, dogId) => {
  const result = await queryPromise(
    req,
    'SELECT * FROM dogLogs WHERE dogId = ?',
    [dogId],
  );
  return result;
};

module.exports = { getLogQuery, getLogsQuery };
