const DatabaseError = require('../../utils/errors/databaseError');
const { formatNumber } = require('../../utils/validateFormat');
const { deleteUser } = require('../../utils/delete');

/**
 *  Queries the database to delete a user and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteUserQuery = async (req) => {
  const userId = formatNumber(req.params.userId);

  try {
    await deleteUser(req, userId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteUserQuery };
