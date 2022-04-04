const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');
const {
  formatNumber, areAllDefined,
} = require('../../utils/validateFormat');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const createDogQuery = async (req) => {
  const familyId = formatNumber(req.params.familyId);
  const { dogName } = req.body;
  // const icon = req.body.icon;

  if (areAllDefined([dogName]) === false) {
    throw new ValidationError('dogName missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogs(familyId, icon, dogName) VALUES (?,?,?)',
      [familyId, undefined, dogName],
    );
    return formatNumber(result.insertId);
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createDogQuery };
