const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatDate, formatNumber, atLeastOneDefined,
} = require('../../utils/database/validateFormat');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateLogQuery = async (req) => {
  const logId = formatNumber(req.params.logId);
  const logDate = formatDate(req.body.logDate);
  const { logNote } = req.body;
  const { logAction } = req.body;
  const { logCustomActionName } = req.body;

  // if all undefined, then there is nothing to update
  if (atLeastOneDefined([logDate, logNote, logAction]) === false) {
    throw new ValidationError('No logDate, logNote, or logAction provided', 'ER_NO_VALUES_PROVIDED');
  }

  try {
    if (logDate) {
      await queryPromise(req, 'UPDATE dogLogs SET logDate = ? WHERE logId = ?', [logDate, logId]);
    }
    if (logNote) {
      await queryPromise(req, 'UPDATE dogLogs SET logNote = ? WHERE logId = ?', [logNote, logId]);
    }
    if (logAction) {
      await queryPromise(req, 'UPDATE dogLogs SET logAction = ? WHERE logId = ?', [logAction, logId]);
    }
    if (logCustomActionName) {
      await queryPromise(req, 'UPDATE dogLogs SET logCustomActionName = ? WHERE logId = ?', [logCustomActionName, logId]);
    }
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateLogQuery };
