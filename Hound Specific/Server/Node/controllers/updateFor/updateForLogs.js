const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatDate, areAllDefined,
} = require('../../utils/database/validateFormat');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateLogQuery = async (req) => {
  const logId = req.params.logId;
  const logDate = formatDate(req.body.logDate);
  const { logNote } = req.body;
  const { logAction } = req.body;
  const { logCustomActionName } = req.body;

  // if all undefined, then there is nothing to update
  if (areAllDefined([logDate, logNote, logAction]) === false) {
    throw new ValidationError('logDate, logNote, or logAction missing', 'ER_VALUE_MISSING');
  }

  try {
    return queryPromise(
      req,
      'UPDATE dogLogs SET logDate = ?, logAction = ?, logCustomActionName = ?, logNote = ?, WHERE logId = ?',
      [logDate, logAction, logCustomActionName, logNote, logId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateLogQuery };
