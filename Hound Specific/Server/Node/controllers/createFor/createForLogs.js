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
  const userId = req.params.userId; // required
  const dogId = req.params.dogId; // required
  const logDate = formatDate(req.body.logDate); // required
  const { logNote } = req.body; // required
  const { logAction } = req.body; // required
  const { logCustomActionName } = req.body; // optional
  const logLastModified = new Date(); // manual

  if (areAllDefined(userId, dogId, logDate, logNote, logAction) === false) {
    throw new ValidationError('userId, dogId, logDate, logNote, or logAction missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, dogId, logDate, logNote, logAction, logCustomActionName, logLastModified],
    );
    return result.insertId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createLogQuery };
