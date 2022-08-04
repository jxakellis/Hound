const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/queryDatabase');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a dog. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
async function updateDogForDogId(connection, dogId, dogName) {
  const dogLastModified = new Date(); // manual

  // if dogName undefined, then there is nothing to update
  if (areAllDefined(connection, dogId, dogName) === false) {
    throw new ValidationError('connection, dogId, or dogName missing', global.constant.error.value.MISSING);
  }

  // updates the dogName for the dogId provided
  const result = await databaseQuery(
    connection,
    'UPDATE dogs SET dogName = ?, dogLastModified = ? WHERE dogId = ?',
    [dogName, dogLastModified, dogId],
  );

  return result;
}

module.exports = { updateDogForDogId };
