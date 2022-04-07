const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/queryPromise');
const {
  formatNumber, atLeastOneDefined,
} = require('../../utils/validateFormat');

/**
 *  Queries the database to update a dog. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateDogQuery = async (req) => {
  // could be updating dogName or dogIcon

  const dogId = formatNumber(req.params.dogId);
  const { dogName } = req.body;
  const { dogIcon } = req.body;

  // if dogName and dogIcon are both undefined, then there is nothing to update
  if (atLeastOneDefined([dogName, dogIcon]) === false) {
    throw new ValidationError('No dogName or dogIcon provided', 'ER_NO_VALUES_PROVIDED');
  }
  try {
    if (dogName) {
      // updates the dogName for the dogId provided, overship of this dog for the user have been verifiied
      await queryPromise(req, 'UPDATE dogs SET dogName = ? WHERE dogId = ?', [dogName, dogId]);
    }
    if (dogIcon) {
      // TO DO implement storage of dogIcon on server
    }
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateDogQuery };
