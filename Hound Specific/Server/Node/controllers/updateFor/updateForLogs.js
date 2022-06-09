const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');

const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatDate, areAllDefined,
} = require('../../main/tools/format/formatObject');

/**
 *  Queries the database to update a log. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateLogQuery = async (req) => {
  const dogId = req.params.dogId;
  const logId = req.params.logId; // required
  const logDate = formatDate(req.body.logDate); // required
  const { logNote } = req.body; // required
  const { logAction } = req.body; // required
  const { logCustomActionName } = req.body; // optional
  const dogLastModified = new Date();
  const logLastModified = dogLastModified; // manual

  // if all undefined, then there is nothing to update
  if (areAllDefined(dogId, logId, logDate, logNote, logAction) === false) {
    throw new ValidationError('dogId, logId, logDate, logNote, or logAction missing', 'ER_VALUE_MISSING');
  }

  try {
    await queryPromise(
      req,
      'UPDATE dogLogs SET logDate = ?, logAction = ?, logCustomActionName = ?, logNote = ?, logLastModified = ? WHERE logId = ?',
      [logDate, logAction, logCustomActionName, logNote, logLastModified, logId],
    );

    // update the dog last modified since one of its compoents was updated
    await queryPromise(
      req,
      'UPDATE dogs SET dogLastModified = ? WHERE dogId = ?',
      [dogLastModified, dogId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateLogQuery };
