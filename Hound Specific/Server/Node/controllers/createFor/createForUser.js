const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatNumber, formatEmail, formatBoolean, areAllDefined,
} = require('../../utils/database/validateFormat');

/**
 *  Queries the database to create a user. If the query is successful, then returns the userId.
 *  If a problem is encountered, creates and throws custom error
 */
const createUserQuery = async (req) => {
  if (req.body.userEmail === '') {
    // userEmail cannot be blank. The else if after will catch this but this statement is to genereate a new, different error.
    throw new ValidationError('userEmail Blank', 'ER_VALUES_BLANK');
  }

  const userEmail = formatEmail(req.body.userEmail);

  if (areAllDefined(userEmail) === false) {
    // userEmail NEEDs to be valid, so throw error if it is invalid
    throw new ValidationError('userEmail Invalid', 'ER_VALUES_INVALID');
  }

  const {
    userIdentifier, userFirstName, userLastName, userNotificationToken,
  } = req.body;

  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isCompactView = formatBoolean(req.body.isCompactView);
  const interfaceStyle = formatNumber(req.body.interfaceStyle);
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;
  // component of the body is missing or invalid
  if (areAllDefined(
    [userIdentifier, userEmail, userFirstName, userLastName, isNotificationEnabled,
      isLoudNotification, isFollowUpEnabled, followUpDelay, isCompactView, interfaceStyle, snoozeLength, notificationSound],
  ) === false) {
    // >=1 of the items is undefined
    throw new ValidationError('userIdentifier, userEmail, userFirstName, userLastName, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isCompactView, interfaceStyle, snoozeLength, or notificationSound missing', 'ER_VALUES_MISSING');
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
      'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isCompactView, interfaceStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?)',
      [userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isCompactView, interfaceStyle, snoozeLength, notificationSound],
    );

    return userId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createUserQuery };
