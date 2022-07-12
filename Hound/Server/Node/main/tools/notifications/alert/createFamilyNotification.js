const { connectionForAlerts } = require('../../database/databaseConnections');
const { alertLogger } = require('../../logging/loggers');
const { formatBoolean } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const { getUserFirstNameLastNameForUserId } = require('../../../../controllers/getFor/getForUser');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');

/**
 * Sends an alert to all of the family members that a new member has joined
 */
async function createFamilyMemberJoinNotification(userId, familyId) {
  try {
    if (global.constant.server.IS_PRODUCTION === false) {
      alertLogger.debug(`createFamilyMemberJoinNotification ${userId}, ${familyId}`);
    }

    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A new family member has joined!';
    const alertBody = `Welcome ${abreviatedFullName} into your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyMemberJoinNotification error:');
    alertLogger.error(error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyMemberLeaveNotification(userId, familyId) {
  try {
    if (global.constant.server.IS_PRODUCTION === false) {
      alertLogger.debug(`createFamilyMemberLeaveNotification ${userId}, ${familyId}`);
    }

    // make sure all params are defined
    if (areAllDefined(userId, familyId) === false) {
      return;
    }

    const abreviatedFullName = await abreviatedFullNameForUserId(userId);

    if (areAllDefined(abreviatedFullName) === false) {
      return;
    }

    // now we can construct the messages
    const alertTitle = 'A family member has left!';
    const alertBody = `${abreviatedFullName} has parted ways with your Hound family`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyMemberLeaveNotification error:');
    alertLogger.error(error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyLockedNotification(userId, familyId, newIsLocked) {
  try {
    if (global.constant.server.IS_PRODUCTION === false) {
      alertLogger.debug(`createFamilyLockedNotification ${userId}, ${familyId}, ${newIsLocked}`);
    }

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
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyLockedNotification error:');
    alertLogger.error(error);
  }
}

/**
 * Sends an alert to all of the family members that one of them has left
 */
async function createFamilyPausedNotification(userId, familyId, newIsPaused) {
  try {
    if (global.constant.server.IS_PRODUCTION === false) {
      alertLogger.debug(`createFamilyPausedNotification ${userId}, ${familyId}, ${newIsPaused}`);
    }

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
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.GENERAL_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createFamilyPausedNotification error:');
    alertLogger.error(error);
  }
}

/**
 * Helper function for createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, and createFamilyPausedNotification
 */
async function abreviatedFullNameForUserId(userId) {
  if (areAllDefined(userId) === false) {
    return undefined;
  }

  const result = await getUserFirstNameLastNameForUserId(connectionForAlerts, userId);

  if (areAllDefined(result, result.userFirstName, result.userLastName) === false) {
    return undefined;
  }

  const abreviatedFullName = formatIntoAbreviatedFullName(result.userFirstName, result.userLastName);

  return abreviatedFullName;
}

module.exports = {
  createFamilyMemberJoinNotification, createFamilyMemberLeaveNotification, createFamilyLockedNotification, createFamilyPausedNotification,
};
