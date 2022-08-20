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
async function getLogForLogId(databaseConnection, logId, forLastDogManagerSynchronization) {
  if (areAllDefined(databaseConnection, logId) === false) {
    throw new ValidationError('databaseConnection or logId missing', global.constant.error.value.MISSING);
  }

  const lastDogManagerSynchronization = formatDate(forLastDogManagerSynchronization);

  let result = areAllDefined(lastDogManagerSynchronization)
    ? await databaseQuery(
      databaseConnection,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logLastModified >= ? AND logId = ? LIMIT 1`,
      [lastDogManagerSynchronization, logId],
    )
    : await databaseQuery(
      databaseConnection,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logId = ? LIMIT 1`,
      [logId],
    );
  [result] = result;

  return result;
}

/**
 *  If the query is successful, returns an array of all the logs for the dogId. Errors not handled
 *  If a problem is encountered, creates and throws custom error
 */
async function getAllLogsForDogId(databaseConnection, dogId, forLastDogManagerSynchronization) {
  if (areAllDefined(databaseConnection, dogId) === false) {
    throw new ValidationError('databaseConnection or dogId missing', global.constant.error.value.MISSING);
  }

  const lastDogManagerSynchronization = formatDate(forLastDogManagerSynchronization);

  const result = areAllDefined(lastDogManagerSynchronization)
    ? await databaseQuery(
      databaseConnection,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE logLastModified >= ? AND dogId = ? LIMIT 18446744073709551615`,
      [lastDogManagerSynchronization, dogId],
    )
    : await databaseQuery(
      databaseConnection,
      `SELECT ${dogLogsColumns} FROM dogLogs WHERE dogId = ? LIMIT 18446744073709551615`,
      [dogId],
    );

  return result;
}

module.exports = { getLogForLogId, getAllLogsForDogId };
