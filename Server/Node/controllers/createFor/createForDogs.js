const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/queryDatabase');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
async function createDogForFamilyId(connection, familyId, activeSubscription, dogName) {
  const dogLastModified = new Date();

  if (areAllDefined(connection, familyId, activeSubscription, activeSubscription.subscriptionNumberOfDogs, dogName) === false) {
    throw new ValidationError('connection, familyId, activeSubscription, or dogName missing', global.constant.error.value.MISSING);
  }

  // only retrieve enough not deleted dogs that would exceed the limit
  const dogs = await databaseQuery(
    connection,
    'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT ?',
    [familyId, activeSubscription.subscriptionNumberOfDogs],
  );

  if (areAllDefined(activeSubscription, dogs) === false) {
    throw new ValidationError('activeSubscription or dogs missing', global.constant.error.value.MISSING);
  }

  // Creating a new dog would exceed the limit
  if (dogs.length >= activeSubscription.subscriptionNumberOfDogs) {
    throw new ValidationError(`Dog limit of ${activeSubscription.subscriptionNumberOfDogs} exceeded`, global.constant.error.family.limit.DOG_TOO_LOW);
  }

  const result = await databaseQuery(
    connection,
    'INSERT INTO dogs(familyId, dogName, dogLastModified) VALUES (?,?,?)',
    [familyId, dogName, dogLastModified],
  );
  return result.insertId;
}

module.exports = { createDogForFamilyId };
