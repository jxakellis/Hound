const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateLogForDogIdLogId = async (req, dogId, logId) => {
  const logDate = formatDate(req.body.logDate); // required
  const { logNote } = req.body; // required
  const { logAction } = req.body; // required
  const { logCustomActionName } = req.body; // optional
  const dogLastModified = new Date();
  const logLastModified = dogLastModified; // manual

  // if all undefined, then there is nothing to update
  if (areAllDefined(req, dogId, logId, logDate, logNote, logAction) === false) {
    throw new ValidationError('req, dogId, logId, logDate, logNote, or logAction missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    req,
    'UPDATE dogLogs SET logDate = ?, logAction = ?, logCustomActionName = ?, logNote = ?, logLastModified = ? WHERE logId = ?',
    [logDate, logAction, logCustomActionName, logNote, logLastModified, logId],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
};

module.exports = { updateLogForDogIdLogId };