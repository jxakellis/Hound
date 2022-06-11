const DatabaseError = require('../../errors/databaseError');
const { connectionForGeneralAlerts } = require('../../database/databaseConnection');
const { alertLogger } = require('../../logging/loggers');
const { formatBoolean, areAllDefined } = require('../../format/formatObject');

const { queryPromise } = require('../../database/queryPromise');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');
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

    const abreviatedFullName = abreviatedFullNameQuery(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A new family member has joined!';
    const alertBody = `Welcome ${abreviatedFullName} into your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody, {});
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

    const abreviatedFullName = abreviatedFullNameQuery(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A family member has left!';
    const alertBody = `${abreviatedFullName} has parted ways with your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyMemberLeaveNotification error:');
    alertLogger.error(error);
  }
};

/**
 * Sends an alert to all of the family members that one of them has left
 */
const createFamilyLockedNotification = async (userId, familyId, newIsLocked) => {
  try {
    alertLogger.debug(`createFamilyLockedNotification ${userId}, ${familyId}, ${newIsLocked}`);
    const isLocked = formatBoolean(newIsLocked);
    // make sure all params are defined
    if (areAllDefined(userId, familyId, isLocked) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameQuery(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    let alertTitle;
    let alertBody;
    if (isLocked) {
      alertTitle = `${abreviatedFullName} locked your family!`;
      alertBody = 'New users are now prevented from joining';
    }
    else {
      alertTitle = `${abreviatedFullName} unlocked your family!`;
      alertBody = 'New users are now allowed to join';
    }

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyLockedNotification error:');
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

    const abreviatedFullName = abreviatedFullNameQuery(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    let alertTitle;
    let alertBody;
    if (isPaused) {
      alertTitle = `${abreviatedFullName} has paused all reminders`;
      alertBody = 'Your alarms are now halted';
    }
    else {
      alertTitle = `${abreviatedFullName} has unpaused all reminders`;
      alertBody = 'Your alarms will now resume';
    }

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyPausedNotification error:');
    alertLogger.error(error);
  }
};

/**
 * Helper function for createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, and createFamilyPausedNotification
 */
const abreviatedFullNameQuery = async (userId) => {
  if (areAllDefined(userId) === false) {
    return undefined;
  }

  // retrieve the userFirstName and userLastName of the user
  let result;
  try {
    result = await queryPromise(
      connectionForGeneralAlerts,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // make sure we got a result
  if (result.length !== 1) {
    return undefined;
  }
  // convert into proper format with formatIntoAbreviatedFullName
  const userFirstName = result[0].userFirstName;
  const userLastName = result[0].userLastName;
  const abreviatedFullName = formatIntoAbreviatedFullName(userFirstName, userLastName);

  return abreviatedFullName;
};

module.exports = {
  createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, createFamilyPausedNotification,
};
