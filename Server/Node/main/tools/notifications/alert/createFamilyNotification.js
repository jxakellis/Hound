const { alertLogger } = require('../../logging/loggers');
const { serverConnectionForGeneral } = require('../../database/databaseConnections');
const { formatBoolean } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const { logServerError } = require('../../logging/logServerError');
const { getUserFirstNameLastNameForUserId } = require('../../../../controllers/getFor/getForUser');
const { sendNotificationForFamilyExcludingUser } = require('../apn/sendNotification');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');

/**
 * Sends an alert to all of the family members that a new member has joined
 */
async function createFamilyMemberJoinNotification(userId, familyId) {
  try {
    alertLogger.debug(`createFamilyMemberJoinNotification ${userId}, ${familyId}`);

    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    // Maxmium possible length: 31 (raw) + 0 (variable) = 31
    const alertTitle = 'A new family member has joined!';

    let alertBody = `Welcome ${''} into your Hound family`;
    const maximumLengthForAbreviatedFullName = global.constant.apn.length.ALERT_BODY - alertBody.length;
    abreviatedFullName.substring(0, maximumLengthForAbreviatedFullName);

    // Maxmium possible length: 31 (raw) + 34 (variable) = 65
    alertBody = `Welcome ${abreviatedFullName} into your Hound family`;

    // we now have the messages and can send our APN
    sendNotificationForFamilyExcludingUser(userId, familyId, global.constant.apn.category.GENERAL, alertTitle, alertBody, {});
  }
  catch (error) {
    logServerError('createFamilyMemberJoinNotification', error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyMemberLeaveNotification(userId, familyId) {
  try {
    alertLogger.debug(`createFamilyMemberLeaveNotification ${userId}, ${familyId}`);

    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    // Maxmium possible length: 25 (raw) + 0 (variable) = 25
    const alertTitle = 'A family member has left!';

    let alertBody = `${''} has parted ways with your Hound family`;
    const maximumLengthForAbreviatedFullName = global.constant.apn.length.ALERT_BODY - alertBody.length;
    abreviatedFullName.substring(0, maximumLengthForAbreviatedFullName);

    // Maxmium possible length: 39 (raw) + 34 (variable) = 73
    alertBody = `${abreviatedFullName} has parted ways with your Hound family`;

    // we now have the messages and can send our APN
    sendNotificationForFamilyExcludingUser(userId, familyId, global.constant.apn.category.GENERAL, alertTitle, alertBody, {});
  }
  catch (error) {
    logServerError('createFamilyMemberLeaveNotification', error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyLockedNotification(userId, familyId, newIsLocked) {
  try {
    alertLogger.debug(`createFamilyLockedNotification ${userId}, ${familyId}, ${newIsLocked}`);

    const isLocked = formatBoolean(newIsLocked);
    // make sure all params are defined
    if (areAllDefined(userId, familyId, isLocked) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    // Maxmium possible length: 27/29 (raw) + 0 (variable) = 27/29
    const alertTitle = isLocked
      ? 'Your family has been locked'
      : 'Your family has been unlocked';

    let alertBody = isLocked
      ? `${''}'s updated your family settings to prevent new users from joining`
      : `${''}'s updated your family settings to allow new users to join`;
    const maximumLengthForAbreviatedFullName = global.constant.apn.length.ALERT_BODY - alertBody.length;
    abreviatedFullName.substring(0, maximumLengthForAbreviatedFullName);

    // Maxmium possible length: 65/58 (raw) + 34 (variable) = 99/92
    alertBody = isLocked
      ? `${abreviatedFullName}'s updated your family settings to prevent new users from joining`
      : `${abreviatedFullName}'s updated your family settings to allow new users to join`;

    // we now have the messages and can send our APN
    sendNotificationForFamilyExcludingUser(userId, familyId, global.constant.apn.category.GENERAL, alertTitle, alertBody, {});
  }
  catch (error) {
    logServerError('createFamilyLockedNotification', error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyPausedNotification(userId, familyId, newIsPaused) {
  try {
    alertLogger.debug(`createFamilyPausedNotification ${userId}, ${familyId}, ${newIsPaused}`);

    const isPaused = formatBoolean(newIsPaused);
    // make sure all params are defined
    if (areAllDefined(userId, familyId, isPaused) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    // Maxmium possible length: 30/32 (raw) + 0 (variable) = 30/32
    const alertTitle = isPaused
      ? 'All reminders have been paused'
      : 'All reminders have been unpaused';

    let alertBody = isPaused
      ? `${''}'s updated your family settings to halt all your alarms`
      : `${''}'s updated your family settings to resume all your alarms`;
    const maximumLengthForAbreviatedFullName = global.constant.apn.length.ALERT_BODY - alertBody.length;
    abreviatedFullName.substring(0, maximumLengthForAbreviatedFullName);

    // Maxmium possible length: 55/57 (raw) + 34 (variable) = 89/91
    alertBody = isPaused
      ? `${abreviatedFullName}'s updated your family settings to halt all your alarms`
      : `${abreviatedFullName}'s updated your family settings to resume all your alarms`;

    // we now have the messages and can send our APN
    sendNotificationForFamilyExcludingUser(userId, familyId, global.constant.apn.category.GENERAL, alertTitle, alertBody, {});
  }
  catch (error) {
    logServerError('createFamilyPausedNotification', error);
  }
}

/**
 * Helper function for createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, and createFamilyPausedNotification
 */
async function abreviatedFullNameForUserId(userId) {
  if (areAllDefined(userId) === false) {
    return undefined;
  }

  const result = await getUserFirstNameLastNameForUserId(serverConnectionForGeneral, userId);

  if (areAllDefined(result, result.userFirstName, result.userLastName) === false) {
    return undefined;
  }

  const abreviatedFullName = formatIntoAbreviatedFullName(result.userFirstName, result.userLastName);

  return abreviatedFullName;
}

module.exports = {
  createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, createFamilyPausedNotification,
};
