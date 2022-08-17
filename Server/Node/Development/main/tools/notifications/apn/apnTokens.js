const { databaseConnectionForGeneral } = require('../../database/establishDatabaseConnections');
const { databaseQuery } = require('../../database/databaseQuery');
const { formatBoolean, formatArray } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const userConfigurationJoin = 'JOIN userConfiguration ON users.userId = userConfiguration.userId';
const familyMembersJoin = 'JOIN familyMembers ON users.userId = familyMembers.userId';

/**
 *  Takes a userId
 *  Returns the userNotificationToken and (optionally) notificationSound of the user if they have a defined userNotificationToken and are notificationEnabled
 *  If an error is encountered, creates and throws custom error
 */
async function getUserToken(userId) {
  if (areAllDefined(userId) === false) {
    return [];
  }
  // retrieve userNotificationToken, notificationSound, and isLoudNotificaiton of a user with the userId, non-null userNotificationToken, and isNotificationEnabled
  const result = await databaseQuery(
    databaseConnectionForGeneral,
    `SELECT users.userNotificationToken, userConfiguration.notificationSound, userConfiguration.isLoudNotification FROM users ${userConfigurationJoin} WHERE users.userId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 1`,
    [userId],
  );

  return parseNotificatonTokenQuery(result);
}

/**
 *  Takes a familyId
 *  Returns the userNotificationToken of users that are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
async function getAllFamilyMemberTokens(familyId) {
  if (areAllDefined(familyId) === false) {
    return [];
  }
  // retrieve userNotificationToken that fit the criteria
  const result = await databaseQuery(
    databaseConnectionForGeneral,
    `SELECT users.userNotificationToken, userConfiguration.notificationSound, userConfiguration.isLoudNotification FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE familyMembers.familyId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
    [familyId],
  );

  return parseNotificatonTokenQuery(result);
}

/**
 *  Takes a userId and familyId
 *  Returns the userNotificationToken of users that aren't the userId, are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
async function getOtherFamilyMemberTokens(userId, familyId) {
  if (areAllDefined(userId, familyId) === false) {
    return [];
  }
  // retrieve userNotificationToken that fit the criteria
  const result = await databaseQuery(
    databaseConnectionForGeneral,
    `SELECT users.userNotificationToken FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE users.userId != ? AND familyMembers.familyId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
    [userId, familyId],
  );

  return parseNotificatonTokenQuery(result);
}

/**
 * Helper method for this file
 * Takes the result from a query for userNotificationToken, notificationSound, and isLoudNotification
 * Returns an array of JSON with userNotificationToken and (if isLoudNotification disabled) notificationSound
 */
function parseNotificatonTokenQuery(forUserNotificationTokens) {
  const userNotificationTokens = formatArray(forUserNotificationTokens);
  if (areAllDefined(userNotificationTokens) === false) {
    return [];
  }

  const userNotificationTokensNotificationSounds = [];

  // If the user isLoudNotification enabled, no need for sound in rawPayload as app plays a sound
  // If the user isLoudNotification disabled, the APN itself have a sound (which will play if the ringer is on)
  for (let i = 0; i < userNotificationTokens.length; i += 1) {
    if (formatBoolean(userNotificationTokens[i].isLoudNotification) === false && areAllDefined(userNotificationTokens[i].notificationSound)) {
      // no loud notification so the APN itself should have a notification sound
      userNotificationTokensNotificationSounds.push({
        userNotificationToken: userNotificationTokens[i].userNotificationToken,
        notificationSound: userNotificationTokens[i].notificationSound.toLowerCase(),
      });
    }
    else {
      // loud notification so app plays audio and no need for notification to play audio
      userNotificationTokensNotificationSounds.push({
        userNotificationToken: userNotificationTokens[i].userNotificationToken,
      });
    }
  }
  return userNotificationTokensNotificationSounds;
}

module.exports = { getUserToken, getAllFamilyMemberTokens, getOtherFamilyMemberTokens };
