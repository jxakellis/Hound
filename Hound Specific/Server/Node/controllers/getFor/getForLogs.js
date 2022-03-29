const { queryPromise } = require('../../utils/queryPromise');

/**
 * Returns the log for the dogId. Errors not handled
 * @param {*} req
 * @param {*} logId
 * @returns
 */
const queryLog = async (req, logId) => {
  const result = await queryPromise(req, 'SELECT * FROM dogLogs WHERE logId = ?', [logId]);
  return result;
};

/**
 * Returns an array of all the logs for the dogId. Errors not handled
 * @param {*} req
 * @param {*} dogId
 * @returns
 */
const queryLogs = async (req, dogId) => {
  const result = await queryPromise(
    req,
    'SELECT * FROM dogLogs WHERE dogId = ?',
    [dogId],
  );
  return result;
};

module.exports = { queryLog, queryLogs };
