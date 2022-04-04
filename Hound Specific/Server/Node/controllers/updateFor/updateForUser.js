const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/queryPromise');
const {
  formatNumber, formatEmail, formatBoolean, atLeastOneDefined, areAllDefined,
} = require('../../utils/validateFormat');

/**
 *  Queries the database to update a user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateUserQuery = async (req) => {
  const userId = formatNumber(req.params.userId);
  const userEmail = formatEmail(req.body.userEmail);
  const { userFirstName } = req.body;
  const { userLastName } = req.body;

  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isPaused = formatBoolean(req.body.isPaused);
  const isCompactView = formatBoolean(req.body.isCompactView);
  const interfaceStyle = formatNumber(req.body.interfaceStyle);
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;

  // checks to see that all needed components are provided
  if (atLeastOneDefined([userEmail, userFirstName, userLastName, isNotificationEnabled,
    isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView,
    interfaceStyle, snoozeLength, notificationSound]) === false) {
    throw new ValidationError('No userEmail, userFirstName, userLastName, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, interfaceStyle, snoozeLength, or notificationSound provided', 'ER_NO_VALUES_PROVIDED');
  }

  try {
    if (areAllDefined(userEmail)) {
      // if userEmail is defined, then its valid
      await queryPromise(
        req,
        'UPDATE users SET userEmail = ? WHERE userId = ?',
        [userEmail, userId],
      );
    }
    if (areAllDefined(userFirstName)) {
      await queryPromise(
        req,
        'UPDATE users SET userFirstName = ? WHERE userId = ?',
        [userFirstName, userId],
      );
    }
    if (areAllDefined(userLastName)) {
      await queryPromise(
        req,
        'UPDATE users SET userLastName = ? WHERE userId = ?',
        [userLastName, userId],
      );
    }
    if (areAllDefined(isNotificationEnabled)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isNotificationEnabled = ? WHERE userId = ?',
        [isNotificationEnabled, userId],
      );
    }
    if (areAllDefined(isLoudNotification)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isLoudNotification = ? WHERE userId = ?',
        [isLoudNotification, userId],
      );
    }
    if (areAllDefined(isFollowUpEnabled)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
        [isFollowUpEnabled, userId],
      );
    }
    if (areAllDefined(followUpDelay)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
        [followUpDelay, userId],
      );
    }
    if (areAllDefined(isPaused)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isPaused = ? WHERE userId = ?',
        [isPaused, userId],
      );
    }
    if (areAllDefined(isCompactView)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isCompactView = ? WHERE userId = ?',
        [isCompactView, userId],
      );
    }
    if (areAllDefined(interfaceStyle)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET interfaceStyle = ? WHERE userId = ?',
        [interfaceStyle, userId],
      );
    }
    if (areAllDefined(snoozeLength)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
        [snoozeLength, userId],
      );
    }
    if (areAllDefined(notificationSound)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
        [notificationSound, userId],
      );
    }
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateUserQuery };
