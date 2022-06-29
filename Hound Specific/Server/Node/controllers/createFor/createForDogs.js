const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { getAllDogsForFamilyId } = require('../getFor/getForDogs');

/**
 *  Queries the database to create a dog. If the query is successful, then returns the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const createDogForFamilyId = async (req, familyId) => {
  const dogName = req.body.dogName; // required
  const dogLastModified = new Date(); // manual

  if (areAllDefined(familyId, dogName) === false) {
    throw new ValidationError('familyId or dogName missing', 'ER_VALUES_MISSING');
  }

  const subscriptionInformation = req.subscriptionInformation;
  const dogs = await getAllDogsForFamilyId(req, familyId);

  if (areAllDefined(subscriptionInformation, dogs) === false) {
    throw new ValidationError('subscriptionInformation or dogs missing', 'ER_VALUES_MISSING');
  }

  // Creating a new dog would exceed the limit
  if (dogs.length >= subscriptionInformation.subscriptionNumberOfDogs) {
    throw new ValidationError(`Dog limit of ${subscriptionInformation.subscriptionNumberOfDogs} exceeded`, 'ER_DOG_LIMIT_EXCEEDED');
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
