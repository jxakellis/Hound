const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/database/queryPromise');

/**
 * Returns the familyCode, familyIsLocked, and  familyMembers for the familyId. Errors not handled
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
    const familyHead = await queryPromise(
      req,
      'SELECT userId, familyIsLocked, familyCode FROM familyHeads WHERE familyId = ?',
      [familyId],
    );

    // iterate through familyMembers
    for (let i = 0; i < familyMembers.length; i += 1) {
      // find which family member is also a family head
      if (familyMembers[i].userId === familyHead[0].userId) {
        // set isFamilyHead property to true
        familyMembers[i].isFamilyHead = true;
        break;
      }
    }
    const result = {
      familyCode: familyHead[0].familyCode,
      familyIsLocked: familyHead[0].familyIsLocked,
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
