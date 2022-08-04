const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/queryDatabase');
const { formatNumber, formatBoolean } = require('../../main/tools/format/formatObject');
const { atLeastOneDefined, areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
async function updateUserForUserId(
  connection,
  userId,
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
  if (areAllDefined(connection, userId) === false) {
    throw new ValidationError('connection or userId missing', global.constant.error.value.MISSING);
  }

  const castedIsNotificationEnabled = formatBoolean(isNotificationEnabled);
  const castedIsLoudNotification = formatBoolean(isLoudNotification);
  const castedIsFollowUpEnabled = formatBoolean(isFollowUpEnabled);
  const castedFollowUpDelay = formatNumber(followUpDelay);
  const castedSnoozeLength = formatNumber(snoozeLength);
  const castedInterfaceStyle = formatNumber(interfaceStyle);
  const castedMaximumNumberOfDisplayedLogs = formatNumber(maximumNumberOfLogsDisplayed);

  // checks to see that all needed components are provided
  if (atLeastOneDefined(
    userNotificationToken,
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
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, interfaceStyle, logsInterfaceScale, remindersInterfaceScale, or maximumNumberOfLogsDisplayed provided', global.constant.error.value.MISSING);
  }

  const promises = [];
  if (areAllDefined(userNotificationToken)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE users SET userNotificationToken = ? WHERE userId = ?',
      [userNotificationToken, userId],
    ));
  }
  if (areAllDefined(castedIsNotificationEnabled)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET isNotificationEnabled = ? WHERE userId = ?',
      [castedIsNotificationEnabled, userId],
    ));
  }
  if (areAllDefined(castedIsLoudNotification)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET isLoudNotification = ? WHERE userId = ?',
      [castedIsLoudNotification, userId],
    ));
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(castedIsFollowUpEnabled)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
      [castedIsFollowUpEnabled, userId],
    ));
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(castedFollowUpDelay)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
      [castedFollowUpDelay, userId],
    ));
  }
  if (areAllDefined(castedSnoozeLength)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
      [castedSnoozeLength, userId],
    ));
  }
  if (areAllDefined(notificationSound)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
      [notificationSound, userId],
    ));
  }
  if (areAllDefined(castedInterfaceStyle)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET interfaceStyle = ? WHERE userId = ?',
      [castedInterfaceStyle, userId],
    ));
  }
  if (areAllDefined(logsInterfaceScale)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET logsInterfaceScale = ? WHERE userId = ?',
      [logsInterfaceScale, userId],
    ));
  }
  if (areAllDefined(remindersInterfaceScale)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET remindersInterfaceScale = ? WHERE userId = ?',
      [remindersInterfaceScale, userId],
    ));
  }
  if (areAllDefined(castedMaximumNumberOfDisplayedLogs)) {
    promises.push(databaseQuery(
      connection,
      'UPDATE userConfiguration SET maximumNumberOfLogsDisplayed = ? WHERE userId = ?',
      [castedMaximumNumberOfDisplayedLogs, userId],
    ));
  }

  await Promise.all(promises);
}

module.exports = { updateUserForUserId };
