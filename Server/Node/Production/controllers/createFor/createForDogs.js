const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
async function createDogForFamilyId(databaseConnection, familyId, activeSubscription, dogName) {
  const dogLastModified = new Date();

  if (areAllDefined(databaseConnection, familyId, activeSubscription, activeSubscription.numberOfDogs, dogName) === false) {
    throw new ValidationError('databaseConnection, familyId, activeSubscription, or dogName missing', global.constant.error.value.MISSING);
  }

  // only retrieve enough not deleted dogs that would exceed the limit
  const dogs = await databaseQuery(
    databaseConnection,
    'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT ?',
    [familyId, activeSubscription.numberOfDogs],
  );

  if (areAllDefined(activeSubscription, dogs) === false) {
    throw new ValidationError('activeSubscription or dogs missing', global.constant.error.value.MISSING);
  }

  // Creating a new dog would exceed the limit
  if (dogs.length >= activeSubscription.numberOfDogs) {
    throw new ValidationError(`Dog limit of ${activeSubscription.numberOfDogs} exceeded`, global.constant.error.family.limit.DOG_TOO_LOW);
  }

  const result = await databaseQuery(
    databaseConnection,
    'INSERT INTO dogs(familyId, dogName, dogLastModified) VALUES (?,?,?)',
    [familyId, dogName, dogLastModified],
  );
  return result.insertId;
}

module.exports = { createDogForFamilyId };
