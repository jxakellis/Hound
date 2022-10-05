const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');

/**
 *  Queries the database to delete a log. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
async function deleteLogForLogId(databaseConnection, dogId, logId) {
  const dogLastModified = new Date();
  const logLastModified = dogLastModified;

  if (areAllDefined(databaseConnection, dogId, logId) === false) {
    throw new ValidationError('databaseConnection, dogId, or logId missing', global.constant.error.value.MISSING);
  }

  const promises = [
    databaseQuery(
      databaseConnection,
      'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE logId = ?',
      [logLastModified, logId],
    ),
    // update the dog last modified since one of its compoents was updated
    databaseQuery(
      databaseConnection,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    )];

  await Promise.all(promises);
}

/**
 *  Queries the database to delete all logs for a dogId. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
async function deleteAllLogsForDogId(databaseConnection, dogId) {
  const dogLastModified = new Date();
  const logLastModified = dogLastModified;

  if (areAllDefined(databaseConnection, dogId) === false) {
    throw new ValidationError('databaseConnection or dogId missing', global.constant.error.value.MISSING);
  }

  const promises = [
    databaseQuery(
      databaseConnection,
      'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE logIsDeleted = 0 AND dogId = ?',
      [logLastModified, dogId],
    ),
    // update the dog last modified since one of its compoents was updated
    databaseQuery(
      databaseConnection,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    ),
  ];

  await Promise.all(promises);
}

module.exports = { deleteLogForLogId, deleteAllLogsForDogId };
