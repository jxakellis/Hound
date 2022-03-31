const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');
const {
  areAllDefined, atLeastOneDefined, formatEmail, formatBoolean, formatNumber,
} = require('../../utils/validateFormat');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {
  // apple user identifier
  const userIdentifier = req.params.userId;
  // hound user id id
  const userId = formatNumber(req.params.userId);
  // userId method of finding corresponding user
  if (userId) {
    // only one user should exist for any userId otherwise the table is broken
    try {
      const userInformation = await queryPromise(
        req,
        'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userId = ?',
        [userId],
      );

      if (userInformation.length !== 1) {
        // successful but empty array, no user to return.
        // Theoretically could be multiple users found but that means the table is broken. Just do catch all
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }

      // array has item(s), meaning there was a user found, successful!
      req.commitQueries(req);
      return res.status(200).json({ result: userInformation });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else if (areAllDefined(userIdentifier)) {
    // userIdentifier method of finding corresponding user(s)
    // userIdentifier already validated

    try {
      const userInformation = await queryPromise(
        req,
        'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userIdentifier = ?',
        [userIdentifier],
      );

      if (userInformation.length !== 1) {
        // successful but empty array, no user to return.
        // Theoretically could be multiple users found but that means the table is broken. Just do catch all
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }

      // array has item(s), meaning there was a user found, successful!
      req.commitQueries(req);
      return res.status(200).json({ result: userInformation });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userIdentifier and userId missing', 'ER_VALUES_MISSING').toJSON);
  }
};

const createUser = async (req, res) => {
  if (req.body.userEmail === '') {
    // userEmail cannot be blank. The else if after will catch this but this statement is to genereate a new, different error.
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userEmail Blank', 'ER_VALUES_BLANK').toJSON);
  }

  const userEmail = formatEmail(req.body.userEmail);

  if (areAllDefined(userEmail) === false) {
    // userEmail NEEDs to be valid, so throw error if it is invalid
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userEmail Invalid', 'ER_VALUES_INVALID').toJSON);
  }

  const { userIdentifier } = req.body;
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
  // component of the body is missing or invalid
  if (areAllDefined(
    [userIdentifier, userEmail, userFirstName, userLastName, isNotificationEnabled,
      isLoudNotification, isFollowUpEnabled, followUpDelay,
      isPaused, isCompactView, interfaceStyle, snoozeLength, notificationSound],
  ) === false) {
    // >=1 of the items is undefined
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userIdentifier, userEmail, userFirstName, userLastName, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, interfaceStyle, snoozeLength, or notificationSound missing', 'ER_VALUES_MISSING').toJSON);
  }

  let userId;

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO users(userIdentifier, userEmail, userFirstName, userLastName) VALUES (?,?,?,?)',
      [userIdentifier, userEmail, userFirstName, userLastName],
    );
    userId = result.insertId;

    await queryPromise(
      req,
      'INSERT INTO userConfiguration(userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, interfaceStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?)',
      [userId, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, interfaceStyle, snoozeLength, notificationSound],
    );

    req.commitQueries(req);
    return res.status(200).json({ result: userId });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const updateUser = async (req, res) => {
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
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No userEmail, userFirstName, userLastName, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, interfaceStyle, snoozeLength, or notificationSound provided', 'ER_NO_VALUES_PROVIDED').toJSON);
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
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const delUser = require('../../utils/delete').deleteUser;

const deleteUser = async (req, res) => {
  const userId = formatNumber(req.params.userId);

  try {
    await delUser(req, userId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

module.exports = {
  getUser, createUser, updateUser, deleteUser,
};
