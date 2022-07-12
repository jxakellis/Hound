const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const userColumns = 'users.userId, users.userNotificationToken, users.userFirstName, users.userLastName, users.userEmail';
const userNameColumns = 'users.userFirstName, users.userLastName';
const userConfigurationColumns = 'userConfiguration.isNotificationEnabled, userConfiguration.isLoudNotification, userConfiguration.isFollowUpEnabled, userConfiguration.followUpDelay, userConfiguration.logsInterfaceScale, userConfiguration.remindersInterfaceScale, userConfiguration.interfaceStyle, userConfiguration.snoozeLength, userConfiguration.notificationSound';

/**
 * Returns the user for the userId. Errors not handled
 */
const getUserForUserId = async (req, userId) => {
  if (areAllDefined(req, userId) === false) {
    throw new ValidationError('req or userId missing', global.constant.error.value.MISSING);
  }

  // have to specifically reference the columns, otherwise familyMembers.userId will override users.userId.
  // Therefore setting userId to null (if there is no family member) even though the userId isn't null.
  const userInformation = await databaseQuery(
    req,
    `SELECT ${userColumns}, familyMembers.familyId, ${userConfigurationColumns} FROM users JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userId = ? LIMIT 1`,
    [userId],
  );

  // array has item(s), meaning there was a user found, successful!
  return userInformation[0];
};

/**
 * Returns the user for the userIdentifier. Errors not handled
 */
const getUserForUserIdentifier = async (req, userIdentifier) => {
  if (areAllDefined(req, userIdentifier) === false) {
    throw new ValidationError('req or userIdentifier missing', global.constant.error.value.MISSING);
  }

  // userIdentifier method of finding corresponding user(s)
  // have to specifically reference the columns, otherwise familyMembers.userId will override users.userId.
  // Therefore setting userId to null (if there is no family member) even though the userId isn't null.
  const userInformation = await databaseQuery(
    req,
    `SELECT ${userColumns}, familyMembers.familyId, ${userConfigurationColumns} FROM users JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userIdentifier = ? LIMIT 1`,
    [userIdentifier],
  );

  // in this case, there was no middleware to verify the userIdentifer so we must make sure that it is valid
  if (userInformation.length === 0) {
    // successful but empty array, no user to return.
    // Theoretically could be multiple users found but that means the table is broken. Just do catch all
    throw new ValidationError('No user found or invalid permissions', global.constant.error.value.INVALID);
  }

  // array has item(s), meaning there was a user found, successful!
  return userInformation[0];
};

const getUserFirstNameLastNameForUserId = async (req, userId) => {
  if (areAllDefined(req, userId) === false) {
    throw new ValidationError('req or userId missing', global.constant.error.value.MISSING);
  }

  const userInformation = await databaseQuery(
    req,
    `SELECT ${userNameColumns} FROM users WHERE users.userId = ? LIMIT 1`,
    [userId],
  );
  return userInformation[0];
};

module.exports = { getUserForUserId, getUserForUserIdentifier, getUserFirstNameLastNameForUserId };
