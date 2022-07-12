const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
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
  ) === false) {
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, snoozeLength, notificationSound, interfaceStyle, logsInterfaceScale, or remindersInterfaceScale provided', global.constant.error.value.MISSING);
  }

  if (areAllDefined(userNotificationToken)) {
    await databaseQuery(
      connection,
      'UPDATE users SET userNotificationToken = ? WHERE userId = ?',
      [userNotificationToken, userId],
    );
  }
  if (areAllDefined(castedIsNotificationEnabled)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET isNotificationEnabled = ? WHERE userId = ?',
      [castedIsNotificationEnabled, userId],
    );
  }
  if (areAllDefined(castedIsLoudNotification)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET isLoudNotification = ? WHERE userId = ?',
      [castedIsLoudNotification, userId],
    );
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(castedIsFollowUpEnabled)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
      [castedIsFollowUpEnabled, userId],
    );
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(castedFollowUpDelay)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
      [castedFollowUpDelay, userId],
    );
  }
  if (areAllDefined(castedSnoozeLength)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
      [castedSnoozeLength, userId],
    );
  }
  if (areAllDefined(notificationSound)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
      [notificationSound, userId],
    );
  }
  if (areAllDefined(castedInterfaceStyle)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET interfaceStyle = ? WHERE userId = ?',
      [castedInterfaceStyle, userId],
    );
  }
  if (areAllDefined(logsInterfaceScale)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET logsInterfaceScale = ? WHERE userId = ?',
      [logsInterfaceScale, userId],
    );
  }
  if (areAllDefined(remindersInterfaceScale)) {
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET remindersInterfaceScale = ? WHERE userId = ?',
      [remindersInterfaceScale, userId],
    );
  }
}

module.exports = { updateUserForUserId };
