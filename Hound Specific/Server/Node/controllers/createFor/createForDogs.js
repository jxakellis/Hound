const { DatabaseError } = require('../../main/tools/errors/databaseError');
const { ValidationError } = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const createDogForFamilyId = async (req, familyId) => {
  const dogName = req.body.dogName; // required
  const dogLastModified = new Date(); // manual

  if (areAllDefined(req, familyId, dogName) === false) {
    throw new ValidationError('req, familyId, or dogName missing', global.constant.error.value.MISSING);
  }

  const subscriptionInformation = req.subscriptionInformation;

  let dogs;
  try {
    // only retrieve enough not deleted dogs that would exceed the limit
    dogs = await queryPromise(
      req,
      'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT ?',
      [familyId, subscriptionInformation.subscriptionNumberOfDogs],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  if (areAllDefined(subscriptionInformation, dogs) === false) {
    throw new ValidationError('subscriptionInformation or dogs missing', global.constant.error.value.MISSING);
  }

  // Creating a new dog would exceed the limit
  if (dogs.length >= subscriptionInformation.subscriptionNumberOfDogs) {
    throw new ValidationError(`Dog limit of ${subscriptionInformation.subscriptionNumberOfDogs} exceeded`, global.constant.error.family.limit.DOG_TOO_LOW);
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogs(familyId, dogName, dogLastModified) VALUES (?,?,?)',
      [familyId, dogName, dogLastModified],
    );
    return result.insertId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createDogForFamilyId };
