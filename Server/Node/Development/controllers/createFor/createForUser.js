const crypto = require('crypto');
const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatNumber, formatEmail, formatBoolean, formatString,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { hash } = require('../../main/tools/format/hash');

/**
 *  Queries the database to create a user. If the query is successful, then returns the userId.
 *  If a problem is encountered, creates and throws custom error
 */
async function createUserForUserIdentifier(
  databaseConnection,
  // userId,
  userIdentifier,
  // userApplicationUsername,
  forUserEmail,
  forUserFirstName,
  forUserLastName,
  forUserNotificationToken,
  // userAccountCreationDate,
  forIsNotificationEnabled,
  forIsLoudNotification,
  forIsFollowUpEnabled,
  forFollowUpDelay,
  forInterfaceStyle,
  forSnoozeLength,
  notificationSound,
  logsInterfaceScale,
  remindersInterfaceScale,
  forMaximumNumberOfLogsDisplayed,
  // lastDogManagerSynchronization,
) {
  if (areAllDefined(databaseConnection, userIdentifier) === false) {
    throw new ValidationError('databaseConnection or userIdentifier missing', global.constant.error.value.MISSING);
  }
  const userAccountCreationDate = new Date();
  const userId = hash(userIdentifier, userAccountCreationDate.toISOString());
  // userIdentifier
  const userApplicationUsername = formatString(crypto.randomUUID(), 36);
  const userEmail = formatEmail(forUserEmail);
  const userFirstName = formatString(forUserFirstName, 32);
  const userLastName = formatString(forUserLastName, 32);
  const userNotificationToken = formatString(forUserNotificationToken, 100);

  const isNotificationEnabled = formatBoolean(forIsNotificationEnabled);
  const isLoudNotification = formatBoolean(forIsLoudNotification);
  const isFollowUpEnabled = formatBoolean(forIsFollowUpEnabled);
  const followUpDelay = formatNumber(forFollowUpDelay);
  const interfaceStyle = formatNumber(forInterfaceStyle);
  const snoozeLength = formatNumber(forSnoozeLength);
  // notificationSound
  // logsInterfaceScale
  // remindersInterfaceScale
  const maximumNumberOfLogsDisplayed = formatNumber(forMaximumNumberOfLogsDisplayed);
  if (areAllDefined(
    userId,
    userIdentifier,
    // userApplicationUsername
    userEmail,
    // userFirstName
    // userLastName
    // userNotificationToken
    userAccountCreationDate,
    isNotificationEnabled,
    isLoudNotification,
    isFollowUpEnabled,
    followUpDelay,
    interfaceStyle,
    snoozeLength,
    notificationSound,
    logsInterfaceScale,
    remindersInterfaceScale,
    maximumNumberOfLogsDisplayed,
  ) === false) {
    throw new ValidationError('userId, userIdentifier, userEmail, userAccountCreationDate, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, interfaceStyle, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, or maximumNumberOfLogsDisplayed missing', global.constant.error.value.MISSING);
  }

  const promises = [
    databaseQuery(
      databaseConnection,
      'INSERT INTO users(userId, userIdentifier, userApplicationUsername, userEmail, userFirstName, userLastName, userNotificationToken, userAccountCreationDate) VALUES (?,?,?,?,?,?,?,?)',
      [userId, userIdentifier, userApplicationUsername, userEmail, userFirstName, userLastName, userNotificationToken, userAccountCreationDate],
    ),
    databaseQuery(
      databaseConnection,
      'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, maximumNumberOfLogsDisplayed) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, maximumNumberOfLogsDisplayed],
    )];
  await Promise.all(promises);

  return userId;
}

module.exports = { createUserForUserIdentifier };
