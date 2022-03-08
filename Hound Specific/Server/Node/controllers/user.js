const { queryPromise } = require('../utils/queryPromise');
const {
  isEmailValid, areAllDefined, atLeastOneDefined, formatBoolean, formatNumber,
} = require('../utils/validateFormat');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {
  let { userEmail } = req.body;
  const userId = formatNumber(req.params.userId);

  // if the users provides an userEmail and a userId then there is a problem. We don't know what to look for as those could be linked to different accounts
  if (userEmail && userId) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters or Body; userEmail and userId provided, only provide one.' });
  }

  // userId method of finding corresponding user
  if (userId) {
    // only one user should exist for any userId otherwise the table is broken
    try {
      const userInformation = await queryPromise(
        req,
        'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userId = ?',
        [userId],
      );

      if (userInformation.length === 0) {
        // successful but empty array, no user to return
        req.commitQueries(req);
        return res.status(204).json({ result: [] });
      }
      else if (userInformation.length !== 1) {
        // more than one user found, shouldn't be possible
        req.rollbackQueries(req);
        return res.status(400).json({ message: 'Invalid Parameters; multiple users found' });
      }

      // array has item(s), meaning there was a user found, successful!
      req.commitQueries(req);
      return res.status(200).json({ result: userInformation });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; user not found', error: error.code });
    }
  }
  else {
    // userEmail method of finding corresponding user(s)
    if (isEmailValid(userEmail) === false) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Body; userEmail Invalid' });
    }
    // userEmail valid, can convert to lower case without producing error
    userEmail = req.body.userEmail.toLowerCase();

    try {
      const userInformation = await queryPromise(
        req,
        'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userEmail = ?',
        [userEmail.toLowerCase()],
      );

      if (userInformation.length === 0) {
        // successful but empty array, no user to return
        req.commitQueries(req);
        return res.status(204).json({ result: userInformation });
      }

      // array has item(s), meaning there was a user found, successful!
      req.commitQueries(req);
      return res.status(200).json({ result: userInformation });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.code });
    }
  }
};

const createUser = async (req, res) => {
  let { userEmail } = req.body;

  if (userEmail === '') {
    // userEmail cannot be blank. The else if after will catch this but this statement is to genereate a new, different error.
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userEmail Invalid', error: 'ER_EMAIL_BLANK' });
  }
  else if (isEmailValid(userEmail) === false) {
    // userEmail NEEDs to be valid, so throw error if it is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userEmail Invalid', error: 'ER_EMAIL_INVALID' });
  }
  // userEmail valid, can convert to lower case without producing error
  userEmail = req.body.userEmail.toLowerCase();

  const { userFirstName } = req.body;
  const { userLastName } = req.body;
  // userFirstName or userLastName can't be blank. Database catches this but this statement generates a new, different error
  if (userFirstName === '') {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userFirstName Blank', error: 'ER_FIRST_NAME_BLANK' });
  }
  else if (userLastName === '') {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userFirstName Blank', error: 'ER_LAST_NAME_BLANK' });
  }

  const isNotificationAuthorized = formatBoolean(req.body.isNotificationAuthorized);
  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isPaused = formatBoolean(req.body.isPaused);
  const isCompactView = formatBoolean(req.body.isCompactView);
  let { darkModeStyle } = req.body;
  // MariaDB starts at 1 for enums, not 0 based so must correct.
  darkModeStyle += 1;
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;
  // component of the body is missing or invalid
  if (areAllDefined(
    [userEmail, userFirstName, userLastName, isNotificationAuthorized, isNotificationEnabled,
      isLoudNotification, isFollowUpEnabled, followUpDelay,
      isPaused, isCompactView, darkModeStyle, snoozeLength, notificationSound],
  ) === false) {
    // >=1 of the items is undefined
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userEmail, userFirstName, userLastName, isNotificationAuthorized, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, darkModeStyle, snoozeLength, or notificationSound missing' });
  }

  let userId;

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
      [userFirstName, userLastName, userEmail],
    );
    userId = result.insertId;

    await queryPromise(
      req,
      'INSERT INTO userConfiguration(userId, isNotificationAuthorized, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [userId, isNotificationAuthorized, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, darkModeStyle, snoozeLength, notificationSound],
    );

    req.commitQueries(req);
    return res.status(200).json({ result: userId });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.code });
  }
};

const updateUser = async (req, res) => {
  const userId = formatNumber(req.params.userId);
  let { userEmail } = req.body;
  const { userFirstName } = req.body;
  const { userLastName } = req.body;

  const isNotificationAuthorized = formatBoolean(req.body.isNotificationAuthorized);
  const isNotificationEnabled = formatBoolean(req.body.isNotificationEnabled);
  const isLoudNotification = formatBoolean(req.body.isLoudNotification);
  const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isPaused = formatBoolean(req.body.isPaused);
  const isCompactView = formatBoolean(req.body.isCompactView);
  const { darkModeStyle } = req.body;
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;

  // checks to see that all needed components are provided
  if (atLeastOneDefined([userEmail, userFirstName, userLastName, isNotificationAuthorized, isNotificationEnabled,
    isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView,
    darkModeStyle, snoozeLength, notificationSound]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No userEmail, userFirstName, userLastName, isNotificationAuthorized, isNotificationEnabled, isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView, darkModeStyle, snoozeLength, or notificationSound provided' });
  }

  try {
    if (areAllDefined(userEmail)) {
      // userEmail only needs to be valid if its provided, therefore check here

      if (isEmailValid(userEmail) === false) {
        req.rollbackQueries(req);
        return res.status(400).json({ message: 'Invalid Body; userEmail Invalid' });
      }
      // userEmail valid, can convert to lower case without producing error
      userEmail = req.body.userEmail.toLowerCase();

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
    if (areAllDefined(isNotificationAuthorized)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET isNotificationAuthorized = ? WHERE userId = ?',
        [isNotificationAuthorized, userId],
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
    if (areAllDefined(darkModeStyle)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET darkModeStyle = ? WHERE userId = ?',
        [darkModeStyle, userId],
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
    return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.code });
  }
};

const delUser = require('../utils/delete').deleteUser;

const deleteUser = async (req, res) => {
  const userId = formatNumber(req.params.userId);

  try {
    await delUser(req, userId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.code });
  }
};

module.exports = {
  getUser, createUser, updateUser, deleteUser,
};
