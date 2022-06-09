const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { formatDate, areAllDefined } = require('../../main/tools/format/formatObject');

/**
 *  If the query is successful, returns the log for the dogId.
 *  If a problem is encountered, creates and throws custom error
*/
const getLogQuery = async (req, logId) => {
  const lastServerSynchronization = formatDate(req.query.lastServerSynchronization);

  // verify that a logId was passed
  if (areAllDefined(logId) === false) {
    throw new ValidationError('logId missing', 'ER_VALUES_MISSING');
  }
  try {
    let result;
    if (areAllDefined(lastServerSynchronization)) {
      result = await queryPromise(
        req,
        'SELECT * FROM dogLogs WHERE logLastModified >= ? AND logId = ? LIMIT 1',
        [lastServerSynchronization, logId],
      );
    }
    else {
      result = await queryPromise(
        req,
        'SELECT * FROM dogLogs WHERE logId = ? LIMIT 1',
        [logId],
      );
    }

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
  const lastServerSynchronization = formatDate(req.query.lastServerSynchronization);

  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }
  try {
    let result;
    if (areAllDefined(lastServerSynchronization)) {
      result = await queryPromise(
        req,
        'SELECT * FROM dogLogs WHERE logLastModified >= ? AND dogId = ? LIMIT 18446744073709551615',
        [lastServerSynchronization, dogId],
      );
    }
    else {
      result = await queryPromise(
        req,
        'SELECT * FROM dogLogs WHERE dogId = ? LIMIT 18446744073709551615',
        [dogId],
      );
    }

    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getLogQuery, getLogsQuery };
