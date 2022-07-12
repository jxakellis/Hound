const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { formatSHA256Hash } = require('../../main/tools/format/formatObject');

// Select every column except for userEmail, userIdentifier, userNotificationToken, and userIsDeleted (by not transmitting, increases network efficiency)
// userEmail, userIdentifier, and userNotificationToken are all private so shouldn't be shown. userIsDeleted isn't currently being used
const usersColumns = 'users.userId, users.userFirstName, users.userLastName';
// Select every column except for familyId, lastPause, lastUnpause, and familyIsDeleted (by not transmitting, increases network efficiency)
// familyId is already known, lastPause + lastUnpause + familyAccountCreationDate have no use client-side and familyIsDeleted isn't currently being used
const familiesColumns = 'userId, familyCode, isLocked, isPaused';

/**
 *  If the query is successful, returns the userId, familyCode, isLocked, isPaused, and familyMembers for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getAllFamilyInformationForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('req or familyId missing', global.constant.error.value.MISSING);
  }
  // family id is validated, therefore we know familyMembers is >= 1 for familyId
  // get family members
  const familyMembers = await databaseQuery(
    req,
    `SELECT ${usersColumns} FROM familyMembers LEFT JOIN users ON familyMembers.userId = users.userId WHERE familyMembers.familyId = ? LIMIT 18446744073709551615`,
    [familyId],
  );
  // find which family member is the head
  let family = await databaseQuery(
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
};

/**
 *  If the query is successful, returns the family members for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getAllFamilyMemberUserIdsForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('req or familyId missing', global.constant.error.value.MISSING);
  }

  const result = await databaseQuery(
    req,
    'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
    [familyId],
  );
  return result;
};

/**
 *  If the query is successful, returns the family member for the userId.
 *  If a problem is encountered, creates and throws custom error
 */
const getFamilyMemberUserIdForUserId = async (req, userId) => {
  // validate that a userId was passed, assume that its in the correct format
  if (areAllDefined(req, userId) === false) {
    throw new ValidationError('req or userId missing', global.constant.error.value.MISSING);
  }

  const result = await databaseQuery(
    req,
    'SELECT userId FROM familyMembers WHERE userId = ? LIMIT 1',
    [userId],
  );
  return result;
};

/**
 *  If the query is successful, returns the userId of the family head
 *  If a problem is encountered, creates and throws custom error
 */
const getFamilyHeadUserIdForFamilyId = async (req, familyId) => {
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('req or familyId missing', global.constant.error.value.MISSING);
  }

  const result = await databaseQuery(
    req,
    'SELECT userId FROM families WHERE familyId = ? LIMIT 1',
    [familyId],
  );

  if (result.length === 0) {
    return undefined;
  }

  return formatSHA256Hash(result[0].userId);
};

module.exports = {
  getAllFamilyInformationForFamilyId, getAllFamilyMemberUserIdsForFamilyId, getFamilyMemberUserIdForUserId, getFamilyHeadUserIdForFamilyId,
};