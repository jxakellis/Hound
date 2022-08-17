const crypto = require('crypto');
const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatNumber, formatEmail, formatBoolean,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { hash } = require('../../main/tools/format/hash');

/**
 *  Queries the database to create a user. If the query is successful, then returns the userId.
 *  If a problem is encountered, creates and throws custom error
 */
async function createUserForUserIdentifier(
  databaseConnection,
  userIdentifier,
  forUserEmail,
  userFirstName,
  userLastName,
  userNotificationToken,
  forIsNotificationEnabled,
  forIsLoudNotification,
  forIsFollowUpEnabled,
  forFollowUpDelay,
  forSnoozeLength,
  notificationSound,
  forInterfaceStyle,
  logsInterfaceScale,
  remindersInterfaceScale,
  forMaximumNumberOfLogsDisplayed,
) {
  if (areAllDefined(databaseConnection, userIdentifier) === false) {
    throw new ValidationError('databaseConnection or userIdentifier missing', global.constant.error.value.MISSING);
  }

  const userAccountCreationDate = new Date();
  const userId = hash(userIdentifier, userAccountCreationDate.toISOString());
  const userApplicationUsername = crypto.randomUUID();

  const userEmail = formatEmail(forUserEmail);
  const isNotificationEnabled = formatBoolean(forIsNotificationEnabled);
  const isLoudNotification = formatBoolean(forIsLoudNotification);
  const isFollowUpEnabled = formatBoolean(forIsFollowUpEnabled);
  const followUpDelay = formatNumber(forFollowUpDelay);
  const snoozeLength = formatNumber(forSnoozeLength);
  const interfaceStyle = formatNumber(forInterfaceStyle);
  const maximumNumberOfLogsDisplayed = formatNumber(forMaximumNumberOfLogsDisplayed);

  // userNotificationToken OPTIONAL
  if (areAllDefined(
    userId,
    userEmail,
    isNotificationEnabled,
    isLoudNotification,
    isFollowUpEnabled,
    followUpDelay,
    snoozeLength,
    notificationSound,
    logsInterfaceScale,
    remindersInterfaceScale,
    interfaceStyle,
    maximumNumberOfLogsDisplayed,
  ) === false) {
    throw new ValidationError('userId, userEmail, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, interfaceStyle, logsInterfaceScale, remindersInterfaceScale, or maximumNumberOfLogsDisplayed missing', global.constant.error.value.MISSING);
  }

  const promises = [
    databaseQuery(
      databaseConnection,
      'INSERT INTO users(userId, userIdentifier, userApplicationUsername, userNotificationToken, userEmail, userFirstName, userLastName, userAccountCreationDate) VALUES (?,?,?,?,?,?,?,?)',
      [userId, userIdentifier, userApplicationUsername, userNotificationToken, userEmail, userFirstName, userLastName, userAccountCreationDate],
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
