const DatabaseError = require('../../utils/errors/databaseError');
const { formatNumber } = require('../../utils/validateFormat');
const { deleteFamily } = require('../../utils/delete');

/**
 *  Queries the database to delete a family and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteFamilyQuery = async (req) => {
  const familyId = formatNumber(req.params.familyId);

  try {
    await deleteFamily(req, familyId);
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { deleteFamilyQuery };
