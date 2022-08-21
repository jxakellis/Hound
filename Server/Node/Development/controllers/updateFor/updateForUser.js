const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatNumber, formatBoolean } = require('../../main/tools/format/formatObject');
const { atLeastOneDefined, areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
async function updateUserForUserId(
  databaseConnection,
  userId,
  userNotificationToken,
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
) {
  if (areAllDefined(databaseConnection, userId) === false) {
    throw new ValidationError('databaseConnection or userId missing', global.constant.error.value.MISSING);
  }
  const isNotificationEnabled = formatBoolean(forIsNotificationEnabled);
  const isLoudNotification = formatBoolean(forIsLoudNotification);
  const isFollowUpEnabled = formatBoolean(forIsFollowUpEnabled);
  const followUpDelay = formatNumber(forFollowUpDelay);
  const interfaceStyle = formatNumber(forInterfaceStyle);
  const snoozeLength = formatNumber(forSnoozeLength);
  // notificationSound
  // logsInterfaceScale
  // remindersInterfaceScale
  const maximumNumberOfDisplayedLogs = formatNumber(forMaximumNumberOfLogsDisplayed);

  // checks to see that all needed components are provided
  if (atLeastOneDefined(
    userNotificationToken,
    isNotificationEnabled,
    isLoudNotification,
    isFollowUpEnabled,
    followUpDelay,
    interfaceStyle,
    snoozeLength,
    notificationSound,
    logsInterfaceScale,
    remindersInterfaceScale,
    maximumNumberOfDisplayedLogs,
  ) === false) {
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, interfaceStyle, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, or maximumNumberOfLogsDisplayed provided', global.constant.error.value.MISSING);
  }

  const promises = [];
  if (areAllDefined(userNotificationToken)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE users SET userNotificationToken = ? WHERE userId = ?',
      [userNotificationToken, userId],
    ));
  }
  if (areAllDefined(isNotificationEnabled)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET isNotificationEnabled = ? WHERE userId = ?',
      [isNotificationEnabled, userId],
    ));
  }
  if (areAllDefined(isLoudNotification)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET isLoudNotification = ? WHERE userId = ?',
      [isLoudNotification, userId],
    ));
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(isFollowUpEnabled)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
      [isFollowUpEnabled, userId],
    ));
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(followUpDelay)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
      [followUpDelay, userId],
    ));
  }
  if (areAllDefined(interfaceStyle)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET interfaceStyle = ? WHERE userId = ?',
      [interfaceStyle, userId],
    ));
  }
  if (areAllDefined(snoozeLength)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
      [snoozeLength, userId],
    ));
  }
  if (areAllDefined(notificationSound)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
      [notificationSound, userId],
    ));
  }
  if (areAllDefined(logsInterfaceScale)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET logsInterfaceScale = ? WHERE userId = ?',
      [logsInterfaceScale, userId],
    ));
  }
  if (areAllDefined(remindersInterfaceScale)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET remindersInterfaceScale = ? WHERE userId = ?',
      [remindersInterfaceScale, userId],
    ));
  }
  if (areAllDefined(maximumNumberOfDisplayedLogs)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET maximumNumberOfLogsDisplayed = ? WHERE userId = ?',
      [maximumNumberOfDisplayedLogs, userId],
    ));
  }

  await Promise.all(promises);
}

module.exports = { updateUserForUserId };
