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
const createUserForUserIdentifier = async (req, userIdentifier) => {
  const userEmail = formatEmail(req.body.userEmail); // required
  const {
    userFirstName, userLastName, userNotificationToken, // optional
  } = req.body;
  const userAccountCreationDate = new Date();

  const userId = await hash(userIdentifier, userAccountCreationDate.toISOString());

  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled); // required
  const isLoudNotification = formatBoolean(req.body.isLoudNotification); // required
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled); // required
  const followUpDelay = formatNumber(req.body.followUpDelay); // required
  const logsInterfaceScale = req.body.logsInterfaceScale; // required
  const remindersInterfaceScale = req.body.remindersInterfaceScale; // required
  const interfaceStyle = formatNumber(req.body.interfaceStyle); // required
  const snoozeLength = formatNumber(req.body.snoozeLength); // required
  const notificationSound = req.body.notificationSound; // required

  // component of the body is missing or invalid
  if (areAllDefined(
    req,
    userId,
    userEmail,
    userIdentifier,
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
    throw new ValidationError('req, userId, userEmail, userIdentifier, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, or notificationSound missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    req,
    'INSERT INTO users(userId, userIdentifier, userNotificationToken, userEmail, userFirstName, userLastName, userAccountCreationDate) VALUES (?,?,?,?,?,?,?)',
    [userId, userIdentifier, userNotificationToken, userEmail, userFirstName, userLastName, userAccountCreationDate],
  );

  await databaseQuery(
    req,
    'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?)',
    [userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, notificationSound],
  );

  return userId;
};

module.exports = { createUserForUserIdentifier };
