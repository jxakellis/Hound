const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');

const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatDate, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateLogQuery = async (req) => {
  const logId = req.params.logId; // required
  const logDate = formatDate(req.body.logDate); // required
  const { logNote } = req.body; // required
  const { logAction } = req.body; // required
  const { logCustomActionName } = req.body; // optional
  const logLastModified = new Date(); // manual

  // if all undefined, then there is nothing to update
  if (areAllDefined(logId, logDate, logNote, logAction) === false) {
    throw new ValidationError('logId, logDate, logNote, or logAction missing', 'ER_VALUE_MISSING');
  }

  try {
    await queryPromise(
      req,
      'UPDATE dogLogs SET logDate = ?, logAction = ?, logCustomActionName = ?, logNote = ?, logLastModified = ? WHERE logId = ?',
      [logDate, logAction, logCustomActionName, logNote, logLastModified, logId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateLogQuery };
