const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { formatNumber, formatBoolean } = require('../../main/tools/format/formatObject');
const { atLeastOneDefined, areAllDefined } = require('../../main/tools/format/validateDefined');

/**
 *  Queries the database to update a user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateUserForUserId = async (req, userId) => {
  const { userNotificationToken } = req.body;

  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const logsInterfaceScale = req.body.logsInterfaceScale;
  const remindersInterfaceScale = req.body.remindersInterfaceScale;
  const interfaceStyle = formatNumber(req.body.interfaceStyle);
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;

  // checks to see that all needed components are provided
  if (atLeastOneDefined(
    userNotificationToken,
    isNotificationEnabled,
    isLoudNotification,
    isFollowUpEnabled,
    followUpDelay,
    logsInterfaceScale,
    remindersInterfaceScale,
    interfaceStyle,
    snoozeLength,
    notificationSound,
  ) === false) {
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, or notificationSound provided', global.constant.error.value.MISSING);
  }

  if (areAllDefined(userNotificationToken)) {
    await databaseQuery(
      req,
      'UPDATE users SET userNotificationToken = ? WHERE userId = ?',
      [userNotificationToken, userId],
    );
  }
  if (areAllDefined(isNotificationEnabled)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET isNotificationEnabled = ? WHERE userId = ?',
      [isNotificationEnabled, userId],
    );
  }
  if (areAllDefined(isLoudNotification)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET isLoudNotification = ? WHERE userId = ?',
      [isLoudNotification, userId],
    );
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(isFollowUpEnabled)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
      [isFollowUpEnabled, userId],
    );
  }
  // don't refresh secondary jobs here, it will be handled by the main controller
  if (areAllDefined(followUpDelay)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
      [followUpDelay, userId],
    );
  }
  if (areAllDefined(logsInterfaceScale)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET logsInterfaceScale = ? WHERE userId = ?',
      [logsInterfaceScale, userId],
    );
  }
  if (areAllDefined(remindersInterfaceScale)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET remindersInterfaceScale = ? WHERE userId = ?',
      [remindersInterfaceScale, userId],
    );
  }
  if (areAllDefined(interfaceStyle)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET interfaceStyle = ? WHERE userId = ?',
      [interfaceStyle, userId],
    );
  }
  if (areAllDefined(snoozeLength)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
      [snoozeLength, userId],
    );
  }
  if (areAllDefined(notificationSound)) {
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
      [notificationSound, userId],
    );
  }
};

module.exports = { updateUserForUserId };
