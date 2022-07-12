const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
async function createDogForFamilyId(connection, familyId, subscriptionInformation, dogName) {
  const dogLastModified = new Date();

  if (areAllDefined(connection, familyId, subscriptionInformation, subscriptionInformation.subscriptionNumberOfDogs, dogName) === false) {
    throw new ValidationError('connection, familyId, subscriptionInformation, or dogName missing', global.constant.error.value.MISSING);
  }

  // only retrieve enough not deleted dogs that would exceed the limit
  const dogs = await databaseQuery(
    connection,
    'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT ?',
    [familyId, subscriptionInformation.subscriptionNumberOfDogs],
  );

  if (areAllDefined(subscriptionInformation, dogs) === false) {
    throw new ValidationError('subscriptionInformation or dogs missing', global.constant.error.value.MISSING);
  }

  // Creating a new dog would exceed the limit
  if (dogs.length >= subscriptionInformation.subscriptionNumberOfDogs) {
    throw new ValidationError(`Dog limit of ${subscriptionInformation.subscriptionNumberOfDogs} exceeded`, global.constant.error.family.limit.DOG_TOO_LOW);
  }

  const result = await databaseQuery(
    connection,
    'INSERT INTO dogs(familyId, dogName, dogLastModified) VALUES (?,?,?)',
    [familyId, dogName, dogLastModified],
  );
  return result.insertId;
}

module.exports = { createDogForFamilyId };
