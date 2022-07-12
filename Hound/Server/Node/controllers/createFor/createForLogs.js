const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a log. If the query is successful, then returns the logId.
 *  If a problem is encountered, creates and throws custom error
 */
const createLogForUserIdDogId = async (req, userId, dogId) => {
  const logDate = formatDate(req.body.logDate); // required
  const { logNote } = req.body; // required
  const { logAction } = req.body; // required
  const { logCustomActionName } = req.body; // optional
  const dogLastModified = new Date();
  const logLastModified = dogLastModified; // manual

  if (areAllDefined(req, userId, dogId, logDate, logNote, logAction) === false) {
    throw new ValidationError('req, userId, dogId, logDate, logNote, or logAction missing', global.constant.error.value.MISSING);
  }

  // only retrieve enough not deleted logs that would exceed the limit
  const logs = await databaseQuery(
    req,
    'SELECT logId FROM dogLogs WHERE logIsDeleted = 0 AND dogId = ? LIMIT ?',
    [dogId, global.constant.limit.NUMBER_OF_LOGS_PER_DOG],
  );

  // make sure that the user isn't creating too many logs
  if (logs.length >= global.constant.limit.NUMBER_OF_LOGS_PER_DOG) {
    throw new ValidationError(`Dog log limit of ${global.constant.limit.NUMBER_OF_LOGS_PER_DOG} exceeded`, global.constant.error.family.limit.LOG_TOO_LOW);
  }

  const result = await databaseQuery(
    req,
    'INSERT INTO dogLogs(userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified],
  );

  // update the dog last modified since one of its compoents was updated
  await databaseQuery(
    req,
    'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );

  return result.insertId;
};

module.exports = { createLogForUserIdDogId };
