const DatabaseError = require('../../errors/databaseError');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForTokens } = require('../../database/databaseConnection');
const { formatBoolean } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const userConfigurationJoin = 'JOIN userConfiguration ON users.userId = userConfiguration.userId';
const familyMembersJoin = 'JOIN familyMembers ON users.userId = familyMembers.userId';

/**
 *  Takes a userId
 *  Returns the userNotificationToken and (optionally) notificationSound of the user if they have a defined userNotificationToken and are notificationEnabled
 *  If an error is encountered, creates and throws custom error
 */
const getUserToken = async (userId) => {
  let result;
  try {
    // retrieve userNotificationToken, notificationSound, and isLoudNotificaiton of a user with the userId, non-null userNotificationToken, and isNotificationEnabled
    result = await queryPromise(
      connectionForTokens,
      `SELECT users.userNotificationToken, userConfiguration.notificationSound, userConfiguration.isLoudNotification FROM users ${userConfigurationJoin} WHERE users.userId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 1`,
      [userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  return parseNotificatonTokenQuery(result);
};

/**
 *  Takes a familyId
 *  Returns the userNotificationToken of users that are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
const getAllFamilyMemberTokens = async (familyId) => {
  let result;
  try {
    // retrieve userNotificationToken that fit the criteria
    result = await queryPromise(
      connectionForTokens,
      `SELECT users.userNotificationToken, userConfiguration.notificationSound, userConfiguration.isLoudNotification FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE familyMembers.familyId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
      [familyId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  return parseNotificatonTokenQuery(result);
};

/**
 *  Takes a userId and familyId
 *  Returns the userNotificationToken of users that aren't the userId, are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
const getOtherFamilyMemberTokens = async (userId, familyId) => {
  let result;
  try {
    // retrieve userNotificationToken that fit the criteria
    result = await queryPromise(
      connectionForTokens,
      `SELECT users.userNotificationToken FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE familyMembers.familyId = ? AND users.userId != ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
      [familyId, userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  return parseNotificatonTokenQuery(result);
};

/**
 * Helper method for this file
 * Takes the result from a query for userNotificationToken, notificationSound, and isLoudNotification
 * Returns an array of JSON with userNotificationToken and (if isLoudNotification disabled) notificationSound
 */
const parseNotificatonTokenQuery = (result) => {
  const formattedArray = [];
  if (areAllDefined(result) === false) {
    return formattedArray;
  }
  // If the user isLoudNotification enabled, no need for sound in rawPayload as app plays a sound
  // If the user isLoudNotification disabled, the APN itself have a sound (which will play if the ringer is on)
  for (let i = 0; i < result.length; i += 1) {
    if (formatBoolean(result[i].isLoudNotification) === false && areAllDefined(result[i].notificationSound)) {
      // no loud notification so the APN itself should have a notification sound
      formattedArray.push({
        userNotificationToken: result[i].userNotificationToken,
        notificationSound: result[i].notificationSound.toLowerCase(),
      });
    }
    else {
      // loud notification so app plays audio and no need for notification to play audio
      formattedArray.push({
        userNotificationToken: result[i].userNotificationToken,
      });
    }
  }
  return formattedArray;
};

module.exports = { getUserToken, getAllFamilyMemberTokens, getOtherFamilyMemberTokens };
