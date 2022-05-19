const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/formatObject');

/**
 *  If the query is successful, returns the familyCode, isLocked, and  familyMembers for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getFamilyInformationForFamilyIdQuery = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }
  // family id is validated, therefore we know familyMembers is >= 1 for familyId
  try {
    // get family members
    const familyMembers = await queryPromise(
      req,
      'SELECT users.userId, users.userFirstName, users.userLastName FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ? LIMIT 18446744073709551615',
      [familyId],
    );
    // find which family member is the head
    let family = await queryPromise(
      req,
      'SELECT userId, isLocked, familyCode, isPaused FROM families WHERE familyId = ? LIMIT 1',
      [familyId],
    );

    family = family[0];
    const result = {
      ...family,
      familyMembers,
    };
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  If the query is successful, returns the family members for the userId.
 *  If a problem is encountered, creates and throws custom error
 */
const getFamilyMembersForUserIdQuery = async (req, userId) => {
  // validate that a userId was passed, assume that its in the correct format
  if (areAllDefined(userId) === false) {
    throw new ValidationError('userId missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'SELECT familyId, userId FROM familyMembers WHERE userId = ? LIMIT 1',
      [userId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getFamilyInformationForFamilyIdQuery, getFamilyMembersForUserIdQuery };
