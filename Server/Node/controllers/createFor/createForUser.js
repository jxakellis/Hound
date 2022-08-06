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
  connection,
  userIdentifier,
  userEmail,
  userFirstName,
  userLastName,
  userNotificationToken,
  isNotificationEnabled,
  isLoudNotification,
  isFollowUpEnabled,
  followUpDelay,
  snoozeLength,
  notificationSound,
  interfaceStyle,
  logsInterfaceScale,
  remindersInterfaceScale,
  maximumNumberOfLogsDisplayed,
) {
  if (areAllDefined(connection, userIdentifier) === false) {
    throw new ValidationError('connection or userIdentifier missing', global.constant.error.value.MISSING);
  }

  const userAccountCreationDate = new Date();
  const userId = hash(userIdentifier, userAccountCreationDate.toISOString());

  const castedUserEmail = formatEmail(userEmail);
  const castedIsNotificationEnabled = formatBoolean(isNotificationEnabled);
  const castedIsLoudNotification = formatBoolean(isLoudNotification);
  const castedIsFollowUpEnabled = formatBoolean(isFollowUpEnabled);
  const castedFollowUpDelay = formatNumber(followUpDelay);
  const castedSnoozeLength = formatNumber(snoozeLength);
  const castedInterfaceStyle = formatNumber(interfaceStyle);
  const castedMaximumNumberOfDisplayedLogs = formatNumber(maximumNumberOfLogsDisplayed);

  // userNotificationToken OPTIONAL
  if (areAllDefined(
    userId,
    castedUserEmail,
    castedIsNotificationEnabled,
    castedIsLoudNotification,
    castedIsFollowUpEnabled,
    castedFollowUpDelay,
    castedSnoozeLength,
    notificationSound,
    logsInterfaceScale,
    remindersInterfaceScale,
    castedInterfaceStyle,
    castedMaximumNumberOfDisplayedLogs,
  ) === false) {
    throw new ValidationError('userId, userEmail, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, interfaceStyle, logsInterfaceScale, remindersInterfaceScale, or maximumNumberOfLogsDisplayed missing', global.constant.error.value.MISSING);
  }

  const promises = [
    databaseQuery(
      connection,
      'INSERT INTO users(userId, userIdentifier, userNotificationToken, userEmail, userFirstName, userLastName, userAccountCreationDate) VALUES (?,?,?,?,?,?,?)',
      [userId, userIdentifier, userNotificationToken, castedUserEmail, userFirstName, userLastName, userAccountCreationDate],
    ),
    databaseQuery(
      connection,
      'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, maximumNumberOfLogsDisplayed) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [userId, castedIsNotificationEnabled, castedIsLoudNotification, castedIsFollowUpEnabled, castedFollowUpDelay, castedSnoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, castedInterfaceStyle, maximumNumberOfLogsDisplayed],
    )];
  await Promise.all(promises);

  return userId;
}

module.exports = { createUserForUserIdentifier };
