const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/database/queryPromise');

/**
 * Returns the familyCode, isLocked, and  familyMembers for the familyId. Errors not handled
 */
const getFamilyInformationForFamilyIdQuery = async (req, familyId) => {
  // family id is validated, therefore we know familyMembers is >= 1 for familyId
  try {
    // get family members
    const familyMembers = await queryPromise(
      req,
      'SELECT users.userId, users.userFirstName, users.userLastName FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ?',
      [familyId],
    );
    // find which family member is the head
    let family = await queryPromise(
      req,
      'SELECT userId, isLocked, familyCode, isPaused, lastPause, lastUnpause FROM families WHERE familyId = ?',
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
 * Returns the family members for the userId. Errors not handled
 */
const getFamilyMembersForUserIdQuery = async (req, userId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT familyId, userId FROM familyMembers WHERE userId = ?',
      [userId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getFamilyInformationForFamilyIdQuery, getFamilyMembersForUserIdQuery };
