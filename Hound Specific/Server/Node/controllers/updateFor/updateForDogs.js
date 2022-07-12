const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a dog. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateDogForDogId = async (req, dogId) => {
  const { dogName } = req.body; // required
  const dogLastModified = new Date(); // manual

  // if dogName undefined, then there is nothing to update
  if (areAllDefined(req, dogId, dogName) === false) {
    throw new ValidationError('req, dogId, or dogName missing', global.constant.error.value.MISSING);
  }

  // updates the dogName for the dogId provided
  const result = await databaseQuery(
    req,
    'UPDATE dogs SET dogName = ?, dogLastModified = ? WHERE dogId = ?',
    [dogName, dogLastModified, dogId],
  );

  return result;
};

module.exports = { updateDogForDogId };
