const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');
const {
  formatDate, formatNumber, areAllDefined,
} = require('../../utils/validateFormat');

/**
 *  Queries the database to create a log. If the query is successful, then returns the logId.
 *  If a problem is encountered, creates and throws custom error
 */
const createLogQuery = async (req) => {
  const dogId = formatNumber(req.params.dogId);
  const logDate = formatDate(req.body.logDate);
  const { logNote } = req.body;
  const { logAction } = req.body;
  const { customActionName } = req.body;

  if (areAllDefined([logDate, logAction]) === false) {
    throw new ValidationError('logDate or logAction missing', 'ER_VALUES_MISSING');
  }
  // else if (logAction === 'Custom' && !customActionName) {
  // see if logAction is being updated to custom and tell the user to provide customActionName if so.
  //   throw new ValidationError('No customActionName provided for "Custom" logAction', 'ER_VALUES_MISSING');
  // }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(dogId, logDate, logNote, logAction, customActionName) VALUES (?, ?, ?, ?, ?)',
      [dogId, logDate, logNote, logAction, customActionName],
    );
    return formatNumber(result.insertId);
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createLogQuery };
