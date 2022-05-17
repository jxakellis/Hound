const { connectionForGeneralAlerts } = require('../../database/databaseConnection');
const { alertLogger } = require('../../logging/loggers');
const { formatBoolean, areAllDefined } = require('../../validation/validateFormat');

const { queryPromise } = require('../../database/queryPromise');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../validation/validateName');
const { GENERAL_CATEGORY } = require('../../../server/constants');

/**
 * Sends an alert to all of the family members that a new member has joined
 */
const createFamilyMemberJoinNotification = async (userId, familyId) => {
  try {
    alertLogger.debug(`createFamilyMemberJoinNotification ${userId}, ${familyId}`);
    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }
    const result = await queryPromise(
      connectionForGeneralAlerts,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );

    if (result.length !== 1) {
      return;
    }
    const userFirstName = result[0].userFirstName;
    const userLastName = result[0].userLastName;
    const fullName = formatIntoAbreviatedFullName(userFirstName, userLastName);

    if (areAllDefined(fullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A new family member has joined!';
    const alertBody = `Welcome ${fullName} into your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody);
  }
  catch (error) {
    alertLogger.error('createFamilyMemberJoinNotification error:');
    alertLogger.error(error);
  }
};

/**
 * Sends an alert to all of the family members that one of them has left
 */
const createFamilyMemberLeaveNotification = async (userId, familyId) => {
  try {
    alertLogger.debug(`createFamilyMemberLeaveNotification ${userId}, ${familyId}`);
    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }
    const result = await queryPromise(
      connectionForGeneralAlerts,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );

    if (result.length !== 1) {
      return;
    }
    const userFirstName = result[0].userFirstName;
    const userLastName = result[0].userLastName;
    const fullName = formatIntoAbreviatedFullName(userFirstName, userLastName);

    if (areAllDefined(fullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A family member has left!';
    const alertBody = `${fullName} has parted ways with your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody);
  }
  catch (error) {
    alertLogger.error('createFamilyMemberLeaveNotification error:');
    alertLogger.error(error);
  }
};

/**
 * Sends an alert to all of the family members that one of them has left
 */
const createFamilyPausedNotification = async (userId, familyId, newIsPaused) => {
  try {
    alertLogger.debug(`createFamilyPausedNotification ${userId}, ${familyId}, ${newIsPaused}`);
    const isPaused = formatBoolean(newIsPaused);
    // make sure all params are defined
    if (areAllDefined(userId, familyId, isPaused) === false) {
      return;
    }

    const result = await queryPromise(
      connectionForGeneralAlerts,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );

    if (result.length !== 1) {
      return;
    }
    const userFirstName = result[0].userFirstName;
    const userLastName = result[0].userLastName;
    const fullName = formatIntoAbreviatedFullName(userFirstName, userLastName);

    if (areAllDefined(fullName) === false) {
      return;
    }

    // now we can construct the messages
    let alertTitle;
    let alertBody;
    if (isPaused) {
      alertTitle = `${fullName} has paused all reminders`;
      alertBody = 'Your alarms are now halted';
    }
    else {
      alertTitle = `${fullName} has unpaused all reminders`;
      alertBody = 'Your alarms will now resume';
    }

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody);
  }
  catch (error) {
    alertLogger.error('createFamilyPausedNotification error:');
    alertLogger.error(error);
  }
};

module.exports = {
  createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyPausedNotification,
};
