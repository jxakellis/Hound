const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
async function updateLogForDogIdLogId(databaseConnection, dogId, logId, forLogDate, logAction, logCustomActionName, logNote) {
  const logDate = formatDate(forLogDate);
  const dogLastModified = new Date();
  const logLastModified = dogLastModified; // manual

  // logCustomActionName optional
  if (areAllDefined(databaseConnection, dogId, logId, logDate, logAction, logNote) === false) {
    throw new ValidationError('databaseConnection, dogId, logId, logDate, logAction, or logNote missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    databaseConnection,
    'UPDATE dogLogs SET logDate = ?, logAction = ?, logCustomActionName = ?, logNote = ?, logLastModified = ? WHERE logId = ?',
    [logDate, logAction, logCustomActionName, logNote, logLastModified, logId],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    databaseConnection,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
}

module.exports = { updateLogForDogIdLogId };
