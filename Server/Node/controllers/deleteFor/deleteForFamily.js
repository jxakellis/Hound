const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatSHA256Hash } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { deleteAllDogsForFamilyId } = require('./deleteForDogs');
const { getUserFirstNameLastNameForUserId } = require('../getFor/getForUser');
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
  let family = databaseQuery(
    connection,
    'SELECT userId FROM families WHERE familyId = ? AND userId = ? LIMIT 18446744073709551615',
    [familyId, userId],
  );
  // find the amount of family members in the family
  let familyMembers = databaseQuery(
    connection,
    'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
    [familyId],
  );

  [family, familyMembers] = await Promise.all([family, familyMembers]);

  // User is the head of the family, so has obligation to it.
  if (family.length === 1) {
    if (familyMembers.length !== 1) {
      // Cannot destroy family until other members are gone
      throw new ValidationError('Family still contains multiple members', global.constant.error.family.leave.INVALID);
    }

    // TO DO NOW check if the family has an active subscription. Only let them delete their family once their subscription expires
    // In the future, we could check if the user's subscription is renewing.
    // so if it is non-renewing / the user canceled it & is letting it expire, we can let them delete their family
    // We just don't want a user with a renewing subscription to delete their family as then their subscription is paying for nothing

    // There is only one user left in the family, which is the API requester
    const leftUserFullName = await getUserFirstNameLastNameForUserId(connection, userId);
    let familyAccountCreationDate = await databaseQuery(
      connection,
      'SELECT familyAccountCreationDate FROM families WHERE familyId = ? LIMIT 1',
      [familyId],
    );
    // only one element
    [familyAccountCreationDate] = familyAccountCreationDate;
    // take familyAccountCreationDate JSON
    familyAccountCreationDate = familyAccountCreationDate.familyAccountCreationDate;

    // Destroy the family now that it is ok to do so
    const promises = [
      databaseQuery(
        connection,
        'DELETE FROM families WHERE familyId = ?',
        [familyId],
      ),
      // keep record of family being delted
      databaseQuery(
        connection,
        'INSERT INTO previousFamilies(familyId, userId, familyAccountCreationDate, familyAccountDeletionDate) VALUES (?,?,?,?)',
        [familyId, userId, familyAccountCreationDate, new Date()],
      ),
      // deletes all users from the family (should only be one)
      databaseQuery(
        connection,
        'DELETE FROM familyMembers WHERE familyId = ?',
        [familyId],
      ),
      // keep record of user leaving
      databaseQuery(
        connection,
        'INSERT INTO previousFamilyMembers(familyId, userId, userFirstName, userLastName, familyLeaveDate, familyLeaveReason) VALUES (?,?,?,?,?,?)',
        [familyId, userId, leftUserFullName.userFirstName, leftUserFullName.userLastName, new Date(), 'familyDeleted'],
      ),
      // delete all the corresponding dog, reminder, and log data
      databaseQuery(
        connection,
        'DELETE dogs, dogReminders, dogLogs FROM dogs LEFT JOIN dogLogs ON dogs.dogId = dogLogs.dogId LEFT JOIN dogReminders ON dogs.dogId = dogReminders.dogId WHERE dogs.familyId = ?',
        [familyId],
      ),
      // delete all the dogs
      deleteAllDogsForFamilyId(connection, familyId),
    ];
    await Promise.all(promises);
  }
  // User is not the head of the family, so no obligation
  else {
    const leftUserFullName = await getUserFirstNameLastNameForUserId(connection, userId);

    const promises = [
      // can leave the family
      // deletes user from family
      databaseQuery(
        connection,
        'DELETE FROM familyMembers WHERE userId = ?',
        [userId],
      ),
      // keep record of user leaving
      databaseQuery(
        connection,
        'INSERT INTO previousFamilyMembers(familyId, userId, userFirstName, userLastName, familyLeaveDate, familyLeaveReason) VALUES (?,?,?,?,?,?)',
        [familyId, userId, leftUserFullName.userFirstName, leftUserFullName.userLastName, new Date(), 'userLeft'],
      ),
    ];

    await Promise.all(promises);
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

  const kickedUserFullName = await getUserFirstNameLastNameForUserId(connection, castedKickUserId);
  const { userFirstName, userLastName } = kickedUserFullName;

  const promises = [
    // kickUserId is valid, kickUserId is different then the requester, requester is the family head so everything is valid
  // kick the user by deleting them from the family
    databaseQuery(
      connection,
      'DELETE FROM familyMembers WHERE userId = ?',
      [castedKickUserId],
    ),
    // keep a record of user kicked
    databaseQuery(
      connection,
      'INSERT INTO previousFamilyMembers(familyId, userId, userFirstName, userLastName, familyLeaveDate, familyLeaveReason) VALUES (?,?,?,?,?,?)',
      [familyId, castedKickUserId, userFirstName, userLastName, new Date(), 'userKicked'],
    ),
  ];

  await Promise.all(promises);

  // remove any pending secondary alarm notifications they have queued
  // The primary alarm notifications retrieve the notification tokens of familyMembers right as they fire, so the user will not be included
  deleteSecondaryAlarmNotificationsForUser(castedKickUserId);
  createFamilyMemberLeaveNotification(castedKickUserId, familyId);
  createUserKickedNotification(castedKickUserId);
}

module.exports = { deleteFamilyForUserIdFamilyId };
