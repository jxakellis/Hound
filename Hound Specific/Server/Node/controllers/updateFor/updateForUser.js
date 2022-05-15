const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');

const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatNumber, formatBoolean, atLeastOneDefined, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

/**
 *  Queries the database to update a user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateUserQuery = async (req) => {
  const userId = req.params.userId;
  // const userEmail = formatEmail(req.body.userEmail);
  const {
    // userFirstName,
    // userLastName,
    userNotificationToken,
  } = req.body;

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
    // userEmail,
    // userFirstName,
    // userLastName,
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
    throw new ValidationError('No userNotificationToken, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale, interfaceStyle, snoozeLength, or notificationSound provided', 'ER_NO_VALUES_PROVIDED');
  }

  try {
    /*
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
    */
    if (areAllDefined(userNotificationToken)) {
      await queryPromise(
        req,
        'UPDATE users SET userNotificationToken = ? WHERE userId = ?',
        [userNotificationToken, userId],
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
    // don't refresh secondary jobs here, it will be handled by the main controller
    if (areAllDefined(isFollowUpEnabled)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isFollowUpEnabled = ? WHERE userId = ?',
        [isFollowUpEnabled, userId],
      );
    }
    // don't refresh secondary jobs here, it will be handled by the main controller
    if (areAllDefined(followUpDelay)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
        [followUpDelay, userId],
      );
    }
    if (areAllDefined(logsInterfaceScale)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET logsInterfaceScale = ? WHERE userId = ?',
        [logsInterfaceScale, userId],
      );
    }
    if (areAllDefined(remindersInterfaceScale)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET remindersInterfaceScale = ? WHERE userId = ?',
        [remindersInterfaceScale, userId],
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
