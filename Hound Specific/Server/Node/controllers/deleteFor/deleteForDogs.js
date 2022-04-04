const DatabaseError = require('../../utils/errors/databaseError');
const { formatNumber } = require('../../utils/validateFormat');
const { deleteDog } = require('../../utils/delete');

/**
 *  Queries the database to delete a dog and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteDogQuery = async (req) => {
  const dogId = formatNumber(req.params.dogId);

  try {
    await deleteDog(req, dogId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteDogQuery };
