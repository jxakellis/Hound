const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/queryPromise');
const {
  formatNumber, formatBoolean, areAllDefined,
} = require('../../utils/validateFormat');

/**
 *  Queries the database to update a family to add a new user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */

// eslint-disable-next-line no-unused-vars
const updateFamilyQuery = async (req) => {
  let familyCode = req.body.familyCode;

  // make sure familyCode was provided
  if (areAllDefined(familyCode) === false) {
    throw new ValidationError('familyCode missing', 'ER_VALUES_MISSING');
  }
  familyCode = familyCode.toUpperCase();

  let result;
  try {
    // retrieve information about the family linked to the familyCode
    result = await queryPromise(
      req,
      'SELECT familyId, familyIsLocked FROM familyHeads WHERE familyCode = ?',
      [familyCode],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // make sure the familyCode was valid by checking if it matched a family
  if (result.length === 0) {
    // result length is zero so there are no families with that familyCode
    throw new ValidationError('familyCode invalid, not found', 'ER_NOT_FOUND');
  }
  result = result[0];
  const isLocked = formatBoolean(result.familyIsLocked);
  // familyCode exists and is linked to a family, now check if family is locked against new members
  if (isLocked === true) {
    throw new ValidationError('familyCode locked', 'ER_FAMILY_LOCKED');
  }

  // the familyCode is valid and linked to an UNLOCKED family
  const familyId = formatNumber(result.familyId);
  const userId = formatNumber(req.params.userId);
  try {
    // insert the user into the family as a family member.
    await queryPromise(
      req,
      'INSERT INTO familyMembers(familyId, userId) VALUES (?, ?)',
      [familyId, userId],
    );
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateFamilyQuery };
