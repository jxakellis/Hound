const DatabaseError = require('../../errors/databaseError');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

const userConfigurationJoin = 'JOIN userConfiguration ON users.userId = userConfiguration.userId';
const familyMembersJoin = 'JOIN familyMembers ON users.userId = familyMembers.userId';

/**
 *  Takes a userId
 *  Returns the userNotificationToken of the user if they have a defined userNotificationToken and are notificationEnabled
 *  If an error is encountered, creates and throws custom error
 */
const getUserToken = async (userId) => {
  try {
    // retrieve userNotificationToken that fit the criteria
    const result = await queryPromise(
      connectionForNotifications,
      `SELECT users.userNotificationToken FROM users ${userConfigurationJoin} WHERE users.userId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 1`,
      [userId],
    );
    // make array that is just the userNotification tokens (instead of current array of JSON)
    const formattedArray = [];
    for (let i = 0; i < result.length; i += 1) {
      formattedArray.push(result[i].userNotificationToken);
    }
    return formattedArray;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Takes a familyId
 *  Returns the userNotificationToken of users that are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
const getAllFamilyMemberTokens = async (familyId) => {
  try {
    // retrieve userNotificationToken that fit the criteria
    const result = await queryPromise(
      connectionForNotifications,
      `SELECT users.userNotificationToken FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE familyMembers.familyId = ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
      [familyId],
    );
    // make array that is just the userNotification tokens (instead of current array of JSON)
    const formattedArray = [];
    for (let i = 0; i < result.length; i += 1) {
      formattedArray.push(result[i].userNotificationToken);
    }
    return formattedArray;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Takes a userId and familyId
 *  Returns the userNotificationToken of users that aren't the userId, are in the family, have a defined userNotificationToken, and are notificationEnabled
 * If an error is encountered, creates and throws custom error
 */
const getOtherFamilyMemberTokens = async (userId, familyId) => {
  try {
    // retrieve userNotificationToken that fit the criteria
    const result = await queryPromise(
      connectionForNotifications,
      `SELECT users.userNotificationToken FROM users ${userConfigurationJoin} ${familyMembersJoin} WHERE familyMembers.familyId = ? AND users.userId != ? AND users.userNotificationToken IS NOT NULL AND userConfiguration.isNotificationEnabled = 1 LIMIT 18446744073709551615`,
      [familyId, userId],
    );
    // make array that is just the userNotification tokens (instead of current array of JSON)
    const formattedArray = [];
    for (let i = 0; i < result.length; i += 1) {
      formattedArray.push(result[i].userNotificationToken);
    }
    return formattedArray;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getUserToken, getAllFamilyMemberTokens, getOtherFamilyMemberTokens };
