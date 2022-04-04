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
  // could be updating dogName or icon

  const dogId = formatNumber(req.params.dogId);
  const { dogName } = req.body;
  const { icon } = req.body;

  // if dogName and icon are both undefined, then there is nothing to update
  if (atLeastOneDefined([dogName, icon]) === false) {
    throw new ValidationError('No dogName or icon provided', 'ER_NO_VALUES_PROVIDED');
  }
  try {
    if (dogName) {
      // updates the dogName for the dogId provided, overship of this dog for the user have been verifiied
      await queryPromise(req, 'UPDATE dogs SET dogName = ? WHERE dogId = ?', [dogName, dogId]);
    }
    if (icon) {
      // implement later
    }
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateDogQuery };
