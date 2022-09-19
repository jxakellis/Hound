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
  forSilentModeIsEnabled,
  forSilentModeStartUTCHour,
  forSilentModeEndUTCHour,
  forSilentModeStartUTCMinute,
  forSilentModeEndUTCMinute,
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
  const maximumNumberOfLogsDisplayed = formatNumber(forMaximumNumberOfLogsDisplayed);
  const silentModeIsEnabled = formatBoolean(forSilentModeIsEnabled);
  const silentModeStartUTCHour = formatNumber(forSilentModeStartUTCHour);
  const silentModeEndUTCHour = formatNumber(forSilentModeEndUTCHour);
  const silentModeStartUTCMinute = formatNumber(forSilentModeStartUTCMinute);
  const silentModeEndUTCMinute = formatNumber(forSilentModeEndUTCMinute);

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
    maximumNumberOfLogsDisplayed,
    silentModeIsEnabled,
    silentModeStartUTCHour,
    silentModeEndUTCHour,
    silentModeStartUTCMinute,
    silentModeEndUTCMinute,
  ) === false) {
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, interfaceStyle, snoozeLength, notificationSound, logsInterfaceScale, remindersInterfaceScale, maximumNumberOfLogsDisplayed, silentModeIsEnabled, silentModeStartUTCHour, silentModeEndUTCHour, silentModeStartUTCMinute, or silentModeEndUTCMinute, provided', global.constant.error.value.MISSING);
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
  if (areAllDefined(maximumNumberOfLogsDisplayed)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET maximumNumberOfLogsDisplayed = ? WHERE userId = ?',
      [maximumNumberOfLogsDisplayed, userId],
    ));
  }
  if (areAllDefined(silentModeIsEnabled)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET silentModeIsEnabled = ? WHERE userId = ?',
      [silentModeIsEnabled, userId],
    ));
  }
  if (areAllDefined(silentModeStartUTCHour)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET silentModeStartUTCHour = ? WHERE userId = ?',
      [silentModeStartUTCHour, userId],
    ));
  }
  if (areAllDefined(silentModeEndUTCHour)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET silentModeEndUTCHour = ? WHERE userId = ?',
      [silentModeEndUTCHour, userId],
    ));
  }
  if (areAllDefined(silentModeStartUTCMinute)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET silentModeStartUTCMinute = ? WHERE userId = ?',
      [silentModeStartUTCMinute, userId],
    ));
  }
  if (areAllDefined(silentModeEndUTCMinute)) {
    promises.push(databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET silentModeEndUTCMinute = ? WHERE userId = ?',
      [silentModeEndUTCMinute, userId],
    ));
  }

  await Promise.all(promises);
}

module.exports = { updateUserForUserId };
