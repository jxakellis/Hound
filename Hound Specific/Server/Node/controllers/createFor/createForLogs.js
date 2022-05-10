const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatDate, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

/**
 *  Queries the database to create a log. If the query is successful, then returns the logId.
 *  If a problem is encountered, creates and throws custom error
 */
const createLogQuery = async (req) => {
  const dogId = req.params.dogId;
  const logDate = formatDate(req.body.logDate);
  const { logNote } = req.body;
  const { logAction } = req.body;
  const { logCustomActionName } = req.body;

  if (areAllDefined(dogId, logDate, logNote, logAction) === false) {
    throw new ValidationError('dogId, logDate, logNote, or logAction missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(dogId, logDate, logNote, logAction, logCustomActionName) VALUES (?, ?, ?, ?, ?)',
      [dogId, logDate, logNote, logAction, logCustomActionName],
    );
    return result.insertId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createLogQuery };
