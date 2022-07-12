const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

// Select every column except for dogId and logLastModified (by not transmitting, increases network efficiency)
// dogId is already known and dogLastModified has no use client-side
const dogLogsColumns = 'logId, userId, logDate, logNote, logAction, logCustomActionName, logIsDeleted';

/**
 *  If the query is successful, returns the log for the dogId.
 *  If a problem is encountered, creates and throws custom error
*/
const getLogForLogId = async (req, logId, lastDogManagerSynchronization) => {
  if (areAllDefined(req, logId) === false) {
    throw new ValidationError('req or logId missing', global.constant.error.value.MISSING);
  }

  const lastSynchronization = formatDate(lastDogManagerSynchronization);

  let result;
  if (areAllDefined(lastSynchronization)) {
    result = await databaseQuery(
      req,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logLastModified >= ? AND logId = ? LIMIT 1`,
      [lastSynchronization, logId],
    );
  }
  else {
    result = await databaseQuery(
      req,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logId = ? LIMIT 1`,
      [logId],
    );
  }

  return result;
};

/**
 *  If the query is successful, returns an array of all the logs for the dogId. Errors not handled
 *  If a problem is encountered, creates and throws custom error
 */
const getAllLogsForDogId = async (req, dogId, lastDogManagerSynchronization) => {
  if (areAllDefined(req, dogId) === false) {
    throw new ValidationError('req or dogId missing', global.constant.error.value.MISSING);
  }

  const lastSynchronization = formatDate(lastDogManagerSynchronization);

  let result;
  if (areAllDefined(lastSynchronization)) {
    result = await databaseQuery(
      req,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logLastModified >= ? AND dogId = ? LIMIT 18446744073709551615`,
      [lastSynchronization, dogId],
    );
  }
  else {
    result = await databaseQuery(
      req,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE dogId = ? LIMIT 18446744073709551615`,
      [dogId],
    );
  }

  return result;
};

module.exports = { getLogForLogId, getAllLogsForDogId };
