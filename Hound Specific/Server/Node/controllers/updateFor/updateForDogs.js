const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');

const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/validation/validateFormat');

/**
 *  Queries the database to update a dog. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateDogQuery = async (req) => {
  // could be updating dogName or dogIcon

  const dogId = req.params.dogId;
  const { dogName } = req.body;

  // if dogName undefined, then there is nothing to update
  if (areAllDefined([dogName]) === false) {
    throw new ValidationError('dogName missing', 'ER_VALUES_MISSING');
  }
  try {
    // updates the dogName for the dogId provided
    return queryPromise(req, 'UPDATE dogs SET dogName = ? WHERE dogId = ?', [dogName, dogId]);

    // TO DO implement storage of dogIcon on server
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateDogQuery };
