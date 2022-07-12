const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');

/**
 *  Queries the database to delete a log. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteLogForLogId = async (req, dogId, logId) => {
  const dogLastModified = new Date();
  const logLastModified = dogLastModified;

  if (areAllDefined(req, dogId, logId) === false) {
    throw new ValidationError('req, dogId, or logId missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    req,
    'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE logId = ?',
    [logLastModified, logId],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
};

/**
 *  Queries the database to delete all logs for a dogId. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteAllLogsForDogId = async (req, dogId) => {
  const dogLastModified = new Date();
  const logLastModified = dogLastModified;

  if (areAllDefined(req, dogId) === false) {
    throw new ValidationError('req or dogId missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    req,
    'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE dogId = ?',
    [logLastModified, dogId],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
};

module.exports = { deleteLogForLogId, deleteAllLogsForDogId };
