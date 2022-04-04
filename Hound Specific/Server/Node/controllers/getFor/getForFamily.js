const DatabaseError = require('../../utils/errors/databaseError');
const { queryPromise } = require('../../utils/queryPromise');

/**
 * Returns the family members for the familyId. Errors not handled
 */
const getFamilyForFamilyIdQuery = async (req, familyId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT users.userId, users.userFirstName, users.userLastName FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ?',
      [familyId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 * Returns the family members for the userId. Errors not handled
 */
const getFamilyForUserIdQuery = async (req, userId) => {
  try {
    const result = await queryPromise(
      req,
      'SELECT * FROM familyMembers WHERE familyMembers.userId = ?',
      [userId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getFamilyForFamilyIdQuery, getFamilyForUserIdQuery };
