const DatabaseError = require('../../main/tools/errors/databaseError');
const { queryPromise } = require('../../main/tools/database/queryPromise');

/**
 *  Queries the database to delete a log. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteLogQuery = async (req, logId) => {
  try {
    await queryPromise(
      req,
      'DELETE FROM dogLogs WHERE logId = ?',
      [logId],
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
const deleteLogsQuery = async (req, dogId) => {
  try {
    await queryPromise(
      req,
      'DELETE FROM dogLogs WHERE dogId = ?',
      [dogId],
    );
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteLogQuery, deleteLogsQuery };
