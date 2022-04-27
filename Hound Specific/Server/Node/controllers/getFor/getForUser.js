const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');

/**
 * Returns the user for the userId. Errors not handled
 */
const getUserForUserIdQuery = async (req, userId) => {
  let userInformation;
  // only one user should exist for any userId otherwise the table is broken
  try {
    // have to specifically reference the columns, otherwise familyMembers.userId will override users.userId.
    // Therefore setting userId to null (if there is no family member) even though the userId isn't null.
    const userInformationSelect = 'users.userId, users.userIdentifier, users.userFirstName, users.userLastName, users.userEmail';
    const userConfigurationSelect = 'userConfiguration.isNotificationEnabled, userConfiguration.isLoudNotification, userConfiguration.isFollowUpEnabled, userConfiguration.followUpDelay, userConfiguration.isCompactView, userConfiguration.interfaceStyle, userConfiguration.snoozeLength, userConfiguration.notificationSound';
    userInformation = await queryPromise(
      req,
      `SELECT ${userInformationSelect}, familyMembers.familyId, ${userConfigurationSelect} FROM users JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userId = ?`,
      [userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  if (userInformation.length !== 1) {
    // successful but empty array, no user to return.
    // Theoretically could be multiple users found but that means the table is broken. Just do catch all
    throw new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND');
  }
  userInformation = userInformation[0];

  // array has item(s), meaning there was a user found, successful!
  return userInformation;
};

/**
 * Returns the user for the userIdentifier. Errors not handled
 */
const getUserForUserIdentifierQuery = async (req, userIdentifier) => {
// userIdentifier method of finding corresponding user(s)
  let userInformation;
  try {
    // have to specifically reference the columns, otherwise familyMembers.userId will override users.userId.
    // Therefore setting userId to null (if there is no family member) even though the userId isn't null.
    const userInformationSelect = 'users.userId, users.userIdentifier, users.userFirstName, users.userLastName, users.userEmail';
    const userConfigurationSelect = 'userConfiguration.isNotificationEnabled, userConfiguration.isLoudNotification, userConfiguration.isFollowUpEnabled, userConfiguration.followUpDelay, userConfiguration.isCompactView, userConfiguration.interfaceStyle, userConfiguration.snoozeLength, userConfiguration.notificationSound';
    userInformation = await queryPromise(
      req,
      `SELECT ${userInformationSelect}, familyMembers.familyId, ${userConfigurationSelect} FROM users JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userIdentifier = ?`,
      [userIdentifier],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
  if (userInformation.length !== 1) {
    // successful but empty array, no user to return.
    // Theoretically could be multiple users found but that means the table is broken. Just do catch all
    throw new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND');
  }
  userInformation = userInformation[0];

  // array has item(s), meaning there was a user found, successful!
  return userInformation;
};

module.exports = { getUserForUserIdQuery, getUserForUserIdentifierQuery };
