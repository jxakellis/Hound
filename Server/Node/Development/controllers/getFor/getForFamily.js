const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { formatSHA256Hash } = require('../../main/tools/format/formatObject');

// Select every column except for userEmail, userIdentifier, and userNotificationToken (by not transmitting, increases network efficiency)
// userEmail, userIdentifier, and userNotificationToken are all private so shouldn't be shown.
const usersColumns = 'users.userId, users.userFirstName, users.userLastName';
// Select every column except for familyId, familyLeaveDate familyLeaveReason
const previousFamilyMembersColumns = 'previousFamilyMembers.userId, previousFamilyMembers.userFirstName, previousFamilyMembers.userLastName';
// Select every column except for familyId, lastPause, and lastUnpause (by not transmitting, increases network efficiency)
// familyId is already known, lastPause + lastUnpause + familyAccountCreationDate have no use client-side
const familiesColumns = 'userId, familyCode, isLocked';

/**
 *  If the query is successful, returns the userId, familyCode, isLocked, and familyMembers for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getAllFamilyInformationForFamilyId(databaseConnection, familyId, activeSubscription) {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }
  // family id is validated, therefore we know familyMembers is >= 1 for familyId
  // find which family member is the head
  const promises = [
    databaseQuery(
      databaseConnection,
      `SELECT ${familiesColumns} FROM families WHERE familyId = ? LIMIT 1`,
      [familyId],
    ),
    // get family members
    getAllFamilyMembersForFamilyId(databaseConnection, familyId),
    getAllPreviousFamilyMembersForFamilyId(databaseConnection, familyId),
  ];

  const [[family], familyMembers, previousFamilyMembers] = await Promise.all(promises);

  const result = {
    ...family,
    familyMembers,
    previousFamilyMembers,
    activeSubscription,
  };

  return result;
}

async function getAllFamilyMembersForFamilyId(databaseConnection, familyId) {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // get family members
  const result = await databaseQuery(
    databaseConnection,
    `SELECT ${usersColumns} FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ? LIMIT 18446744073709551615`,
    [familyId],
  );

  return result;
}

async function getAllPreviousFamilyMembersForFamilyId(databaseConnection, familyId) {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // get family members
  // TO DO NOW if there are multiple entries for the same userId & familyId previousFamilyMembers, take the most recent entry.
  // to achieve this: GROUP BY userId ORDER BY leaveDate DESC
  const result = await databaseQuery(
    databaseConnection,
    `SELECT ${previousFamilyMembersColumns} FROM previousFamilyMembers WHERE familyId = ? LIMIT 18446744073709551615`,
    [familyId],
  );

  return result;
}

/**
 *  If the query is successful, returns the family member for the userId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getFamilyMemberUserIdForUserId(databaseConnection, userId) {
  // validate that a userId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, userId) === false) {
    throw new ValidationError('databaseConnection or userId missing', global.constant.error.value.MISSING);
  }

  const result = await databaseQuery(
    databaseConnection,
    'SELECT userId FROM familyMembers WHERE userId = ? LIMIT 1',
    [userId],
  );

  return result;
}

/**
 *  If the query is successful, returns the userId of the family head
 *  If a problem is encountered, creates and throws custom error
 */
async function getFamilyHeadUserIdForFamilyId(databaseConnection, familyId) {
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  let result = await databaseQuery(
    databaseConnection,
    'SELECT userId FROM families WHERE familyId = ? LIMIT 1',
    [familyId],
  );

  [result] = result;
  if (areAllDefined(result) === false) {
    return undefined;
  }

  return formatSHA256Hash(result.userId);
}

module.exports = {
  getAllFamilyInformationForFamilyId, getAllFamilyMembersForFamilyId, getFamilyMemberUserIdForUserId, getFamilyHeadUserIdForFamilyId,
};
