const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatSHA256Hash } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { deleteAllDogsForFamilyId } = require('./deleteForDogs');
const { getFamilyHeadUserIdForFamilyId } = require('../getFor/getForFamily');

const { createUserKickedNotification } = require('../../main/tools/notifications/alert/createUserKickedNotification');
const { createFamilyMemberLeaveNotification } = require('../../main/tools/notifications/alert/createFamilyNotification');
const { deleteSecondaryAlarmNotificationsForUser } = require('../../main/tools/notifications/alarm/deleteAlarmNotification');

/**
 *  Queries the database to either remove the user from their current family (familyMember) or delete the family and everything nested under it (families).
 *  If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
async function deleteFamilyForUserIdFamilyId(connection, userId, familyId, kickUserId) {
  const castedKickUserId = formatSHA256Hash(kickUserId);

  // kickUserId is optional
  if (areAllDefined(connection, userId, familyId) === false) {
    throw new ValidationError('connection, userId, or familyId missing', global.constant.error.value.MISSING);
  }

  // TO DO add table for previousFamilyMembers.
  // This will only store the familyId, userId, userFirstName, and userLastName of any one in the family that has left / been kicked
  // Therefore, when trying to see who created a log (even if they have left the family), you can still see a corresponding name.
  if (areAllDefined(castedKickUserId)) {
    await kickFamilyMember(connection, userId, familyId, castedKickUserId);
  }
  else {
    await deleteFamily(connection, userId, familyId);
  }
}

/**
 * Helper method for deleteFamilyForUserIdFamilyId, goes through checks to remove a user from their family
 * If the user is the head of the family (and there are no other family members), we delete the family
 */
async function deleteFamily(connection, userId, familyId) {
  if (areAllDefined(connection, userId, familyId) === false) {
    throw new ValidationError('connection, userId, or familyId missing', global.constant.error.value.MISSING);
  }

  // find out if the user is the family head
  const family = databaseQuery(
    connection,
    'SELECT userId FROM families WHERE familyId = ? AND userId = ? LIMIT 18446744073709551615',
    [familyId, userId],
  );
  // find the amount of family members in the family
  const familyMembers = databaseQuery(
    connection,
    'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
    [familyId],
  );

  await Promise.all(family, familyMembers);

  // User is the head of the family, so has obligation to it.
  if (family.length === 1) {
    if (familyMembers.length !== 1) {
      // Cannot destroy family until other members are gone
      throw new ValidationError('Family still contains multiple members', global.constant.error.family.leave.INVALID);
    }

    // can destroy the family
    // delete all the family heads (should be one)
    await databaseQuery(
      connection,
      'DELETE FROM families WHERE familyId = ?',
      [familyId],
    );
    // deletes all users from the family
    await databaseQuery(
      connection,
      'DELETE FROM familyMembers WHERE familyId = ?',
      [familyId],
    );
    // delete all the corresponding dog, reminder, and log data
    await databaseQuery(
      connection,
      'DELETE dogs, dogReminders, dogLogs FROM dogs LEFT JOIN dogLogs ON dogs.dogId = dogLogs.dogId LEFT JOIN dogReminders ON dogs.dogId = dogReminders.dogId WHERE dogs.familyId = ?',
      [familyId],
    );

    // delete all the dogs
    await deleteAllDogsForFamilyId(connection, familyId);
  }
  // User is not the head of the family, so no obligation
  else {
  // can leave the family
    // deletes user from family
    await databaseQuery(
      connection,
      'DELETE FROM familyMembers WHERE userId = ?',
      [userId],
    );
  }

  // now that the user has successfully left their family (or destroyed it), we can send a notification to remaining members
  // NOTE: in the case of the user being the family head (aka the only family members if we reached this point),
  // this will ultimately find no userNotificationTokens for the other family members and send no APN
  createFamilyMemberLeaveNotification(userId, familyId);
}

/**
 * Helper method for deleteFamilyForUserIdFamilyId, goes through checks to attempt to kick a user from the family
 */
async function kickFamilyMember(connection, userId, familyId, kickUserId) {
  const castedKickUserId = formatSHA256Hash(kickUserId);

  // have to specify who to kick from the family
  if (areAllDefined(connection, userId, familyId, castedKickUserId) === false) {
    throw new ValidationError('connection, userId, familyId, or kickUserId missing', global.constant.error.value.MISSING);
  }
  // a user cannot kick themselves
  if (userId === castedKickUserId) {
    throw new ValidationError("You can't kick yourself from your family", global.constant.error.value.INVALID);
  }
  const familyHeadUserId = await getFamilyHeadUserIdForFamilyId(connection, familyId);

  // check to see if the user is the family head, as only the family head has permissions to kick
  if (familyHeadUserId !== userId) {
    throw new ValidationError('You are not the family head. Only the family head can kick family members', global.constant.error.family.permission.INVALID);
  }

  // kickUserId is valid, kickUserId is different then the requester, requester is the family head so everything is valid
  // kick the user by deleting them from the family
  await databaseQuery(
    connection,
    'DELETE FROM familyMembers WHERE userId = ?',
    [castedKickUserId],
  );

  // remove any pending secondary alarm notifications they have queued
  // The primary alarm notifications retrieve the notification tokens of familyMembers right as they fire, so the user will not be included
  deleteSecondaryAlarmNotificationsForUser(castedKickUserId);
  createFamilyMemberLeaveNotification(castedKickUserId, familyId);
  createUserKickedNotification(castedKickUserId);
}

module.exports = { deleteFamilyForUserIdFamilyId };
