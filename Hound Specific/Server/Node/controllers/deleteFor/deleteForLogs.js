const { DatabaseError } = require('../../main/tools/errors/databaseError');
const { ValidationError } = require('../../main/tools/errors/validationError');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { queryPromise } = require('../../main/tools/database/queryPromise');

/**
 *  Queries the database to delete a log. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteLogForLogId = async (req, dogId, logId) => {
  try {
    const dogLastModified = new Date();
    const logLastModified = dogLastModified;

    if (areAllDefined(req, dogId, logId) === false) {
      throw new ValidationError('req, dogId, or logId missing', global.constant.error.value.MISSING);
    }

    await queryPromise(
      req,
      'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE logId = ?',
      [logLastModified, logId],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );

    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Queries the database to delete all logs for a dogId. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteAllLogsForDogId = async (req, dogId) => {
  try {
    const dogLastModified = new Date();
    const logLastModified = dogLastModified;

    if (areAllDefined(req, dogId) === false) {
      throw new ValidationError('req or dogId missing', global.constant.error.value.MISSING);
    }

    await queryPromise(
      req,
      'UPDATE dogLogs SET logIsDeleted = 1, logLastModified = ? WHERE dogId = ?',
      [logLastModified, dogId],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );

    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteLogForLogId, deleteAllLogsForDogId };
