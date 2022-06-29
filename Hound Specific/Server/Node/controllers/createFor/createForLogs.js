const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { formatDate } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { NUMBER_OF_LOGS_PER_DOG } = require('../../main/server/constants');

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

  if (areAllDefined(userId, dogId, logDate, logNote, logAction) === false) {
    throw new ValidationError('userId, dogId, logDate, logNote, or logAction missing', 'ER_VALUES_MISSING');
  }

  let numberOfLogs;
  try {
    numberOfLogs = await queryPromise(
      req,
      'SELECT logId FROM dogLogs WHERE logIsDeleted = 0 AND dogId = ? LIMIT 18446744073709551615',
      [dogId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // make sure that the user isn't creating too many logs
  if (numberOfLogs.length >= NUMBER_OF_LOGS_PER_DOG) {
    throw new ValidationError(`Dog log limit of ${NUMBER_OF_LOGS_PER_DOG} exceeded`, 'ER_LOGS_LIMIT_EXCEEDED');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );

    return result.insertId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createLogForUserIdDogId };
