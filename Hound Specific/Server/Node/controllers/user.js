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
      return res.status(400).json({ message: 'Invalid Parameters; user not found', error: error.message });
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
      return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message });
    }
  }
};

const createUser = async (req, res) => {
  let { userEmail } = req.body;

  if (isEmailValid(userEmail) === false) {
    // userEmail NEEDs to be valid, so throw error if it is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userEmail Invalid' });
  }
  // userEmail valid, can convert to lower case without producing error
  userEmail = req.body.userEmail.toLowerCase();

  const { userFirstName } = req.body;
  const { userLastName } = req.body;
  const notificationAuthorized = formatBoolean(req.body.notificationAuthorized);
  const notificationEnabled = formatBoolean(req.body.notificationEnabled);
  const loudNotifications = formatBoolean(req.body.loudNotifications);
  const showTerminationAlert = formatBoolean(req.body.showTerminationAlert);
  const followUp = formatBoolean(req.body.followUp);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isPaused = formatBoolean(req.body.isPaused);
  const compactView = formatBoolean(req.body.compactView);
  const { darkModeStyle } = req.body;
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;

  // component of the body is missing or invalid
  if (areAllDefined(
    [userEmail, userFirstName, userLastName, notificationAuthorized, notificationEnabled,
      loudNotifications, showTerminationAlert, followUp, followUpDelay,
      isPaused, compactView, darkModeStyle, snoozeLength, notificationSound],
  ) === false) {
    // >=1 of the items is undefined
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; userEmail, userFirstName, userLastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound missing' });
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
      'INSERT INTO userConfiguration(userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
      [userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound],
    );

    req.commitQueries(req);
    return res.status(200).json({ result: userId });
  }
  catch (errorOne) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; Database query failed', error: errorOne.message });
  }
};

const updateUser = async (req, res) => {
  const userId = formatNumber(req.params.userId);
  let { userEmail } = req.body;
  const { firstName } = req.body;
  const { lastName } = req.body;

  const notificationAuthorized = formatBoolean(req.body.notificationAuthorized);
  const notificationEnabled = formatBoolean(req.body.notificationEnabled);
  const loudNotifications = formatBoolean(req.body.loudNotifications);
  const showTerminationAlert = formatBoolean(req.body.showTerminationAlert);
  const followUp = formatBoolean(req.body.followUp);
  const followUpDelay = formatNumber(req.body.followUpDelay);
  const isPaused = formatBoolean(req.body.isPaused);
  const compactView = formatBoolean(req.body.compactView);
  const { darkModeStyle } = req.body;
  const snoozeLength = formatNumber(req.body.snoozeLength);
  const { notificationSound } = req.body;

  // checks to see that all needed components are provided
  if (atLeastOneDefined([userEmail, firstName, lastName, notificationAuthorized, notificationEnabled,
    loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView,
    darkModeStyle, snoozeLength, notificationSound]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No userEmail, firstName, lastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound provided' });
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
    if (areAllDefined(firstName)) {
      await queryPromise(
        req,
        'UPDATE users SET userFirstName = ? WHERE userId = ?',
        [firstName, userId],
      );
    }
    if (areAllDefined(lastName)) {
      await queryPromise(
        req,
        'UPDATE users SET userLastName = ? WHERE userId = ?',
        [lastName, userId],
      );
    }
    if (areAllDefined(notificationAuthorized)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET notificationAuthorized = ? WHERE userId = ?',
        [notificationAuthorized, userId],
      );
    }
    if (areAllDefined(notificationEnabled)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET notificationEnabled = ? WHERE userId = ?',
        [notificationEnabled, userId],
      );
    }
    if (areAllDefined(loudNotifications)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET loudNotifications = ? WHERE userId = ?',
        [loudNotifications, userId],
      );
    }
    if (areAllDefined(showTerminationAlert)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET showTerminationAlert = ? WHERE userId = ?',
        [showTerminationAlert, userId],
      );
    }
    if (areAllDefined(followUp)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET followUp = ? WHERE userId = ?',
        [followUp, userId],
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
    if (areAllDefined(compactView)) {
      await queryPromise(
        req,
        'UPDATE userConfiguration SET compactView = ? WHERE userId = ?',
        [compactView, userId],
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
    return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message });
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
    return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.message });
  }
};

module.exports = {
  getUser, createUser, updateUser, deleteUser,
};
