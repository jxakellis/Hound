const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');

const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/formatObject');

/**
 *  Queries the database to update a dog. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateDogQuery = async (req) => {
  const dogId = req.params.dogId; // required
  const { dogName } = req.body; // required
  const dogLastModified = new Date(); // manual

  // if dogName undefined, then there is nothing to update
  if (areAllDefined(dogId, dogName) === false) {
    throw new ValidationError('dogId or dogName missing', 'ER_VALUES_MISSING');
  }

  try {
    // updates the dogName for the dogId provided
    return queryPromise(
      req,
      'UPDATE dogs SET dogName = ?, dogLastModified = ? WHERE dogId = ?',
      [dogName, dogLastModified, dogId],
    );

    // TO DO implement storage of dogIcon on server
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateDogQuery };
