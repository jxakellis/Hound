const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatNumber, formatEmail, formatBoolean, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

/**
 *  Queries the database to create a user. If the query is successful, then returns the userId.
 *  If a problem is encountered, creates and throws custom error
 */
const createUserQuery = async (req) => {
  const userEmail = formatEmail(req.body.userEmail);
  const {
    userIdentifier, userFirstName, userLastName, userNotificationToken,
  } = req.body;

  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const logsInterfaceScale = req.body.logsInterfaceScale;
  const remindersInterfaceScale = req.body.remindersInterfaceScale;
  const interfaceStyle = formatNumber(req.body.interfaceStyle);
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const notificationSound = req.body.notificationSound;
  // component of the body is missing or invalid
  // userNotificationToken is optional as at this point the client may not have it
  if (areAllDefined(
    [userEmail, userIdentifier,
      isNotificationEnabled, isLoudNotification, isFollowUpEnabled,
      followUpDelay, logsInterfaceScale, remindersInterfaceScale,
      interfaceStyle, snoozeLength, notificationSound],
  ) === false) {
    // >=1 of the items is undefined
    throw new ValidationError('userIdentifier, userEmail, userFirstName, userLastName, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, or notificationSound missing', 'ER_VALUES_MISSING');
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO users(userIdentifier, userNotificationToken, userEmail, userFirstName, userLastName) VALUES (?,?,?,?,?)',
      [userIdentifier, userNotificationToken, userEmail, userFirstName, userLastName],
    );
    const userId = result.insertId;

    await queryPromise(
      req,
      'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?)',
      [userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, notificationSound],
    );

    return userId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createUserQuery };
