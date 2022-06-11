const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/formatObject');

// Select every column except for userEmail, userIdentifier, userNotificationToken, and userIsDeleted (by not transmitting, increases network efficiency)
// userEmail, userIdentifier, and userNotificationToken are all private so shouldn't be shown. userIsDeleted isn't currently being used
const usersColumns = 'users.userId, users.userFirstName, users.userLastName';
// Select every column except for familyId, lastPause, lastUnpause, and familyIsDeleted (by not transmitting, increases network efficiency)
// familyId is already known, lastPause + lastUnpause have no use client-side and familyIsDeleted isn't currently being used
const familiesColumns = 'userId, familyCode, isLocked, isPaused';

/**
 *  If the query is successful, returns the userId, familyCode, isLocked, isPaused, and familyMembers for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getFamilyInformationForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }
  // family id is validated, therefore we know familyMembers is >= 1 for familyId
  try {
    // get family members
    const familyMembers = await queryPromise(
      req,
      `SELECT ${usersColumns} FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ? LIMIT 18446744073709551615`,
      [familyId],
    );
    // find which family member is the head
    let family = await queryPromise(
      req,
      `SELECT ${familiesColumns} FROM families WHERE familyId = ? LIMIT 1`,
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
const getFamilyMembersForUserId = async (req, userId) => {
  // validate that a userId was passed, assume that its in the correct format
  if (areAllDefined(userId) === false) {
    throw new ValidationError('userId missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      `SELECT ${usersColumns} FROM familyMembers WHERE userId = ? LIMIT 1`,
      [userId],
    );
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getFamilyInformationForFamilyId, getFamilyMembersForUserId };
