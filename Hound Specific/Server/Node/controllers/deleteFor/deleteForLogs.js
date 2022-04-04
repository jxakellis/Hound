const DatabaseError = require('../../utils/errors/databaseError');
const { formatNumber } = require('../../utils/validateFormat');
const { deleteLog } = require('../../utils/delete');

/**
 *  Queries the database to delete a log and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteLogQuery = async (req) => {
  const logId = formatNumber(req.params.logId);

  try {
    await deleteLog(req, logId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteLogQuery };
