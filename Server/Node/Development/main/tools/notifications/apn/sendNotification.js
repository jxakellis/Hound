const { apnLogger } = require('../../logging/loggers');

const { logServerError } = require('../../logging/logServerError');
const { formatArray } = require('../../format/formatObject');
const { areAllDefined } = require('../../format/validateDefined');

const { sendAPN } = require('./sendAPN');
const { getUserToken, getAllFamilyMemberTokens, getOtherFamilyMemberTokens } = require('./apnTokens');

/**
* Takes a userId and retrieves the userNotificationToken for the user
* Invokes sendAPN with the tokens, alertTitle, and alertBody
*/
async function sendNotificationForUser(userId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendNotificationForUser ${userId}, ${category}, ${alertTitle}, ${alertBody}`);

  if (areAllDefined(userId) === false) {
    return;
  }

  try {
    // get tokens of all qualifying family members that aren't the user
    const tokenAndSounds = formatArray(await getUserToken(userId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendNotificationForUser', error);
  }
}

/**
 * Takes a familyId and retrieves the userNotificationToken for all familyMembers
 * Invokes sendAPN with the tokens, alertTitle, and alertBody
 */
async function sendNotificationForFamily(familyId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendNotificationForFamily ${familyId}, ${category}, ${alertTitle}, ${alertBody}, ${customPayload}`);

  try {
    // get notification tokens of all qualifying family members
    const tokenAndSounds = formatArray(await getAllFamilyMemberTokens(familyId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendNotificationForFamily', error);
  }
}

/**
 * Takes a familyId and retrieves the userNotificationToken for all familyMembers (excluding the userId provided)
 * Invokes sendAPN with the tokens, alertTitle, and alertBody
 */
async function sendNotificationForFamilyExcludingUser(userId, familyId, category, alertTitle, alertBody, customPayload) {
  apnLogger.debug(`sendNotificationForFamilyExcludingUser ${userId}, ${familyId}, ${category}, ${alertTitle}, ${alertBody}, ${customPayload}`);

  try {
    // get tokens of all qualifying family members that aren't the user
    const tokenAndSounds = formatArray(await getOtherFamilyMemberTokens(userId, familyId));

    if (areAllDefined(tokenAndSounds, category, alertTitle, alertBody, customPayload) === false || tokenAndSounds.length === 0) {
      return;
    }

    // sendAPN if there are > 0 user notification tokens
    for (let i = 0; i < tokenAndSounds.length; i += 1) {
      sendAPN(tokenAndSounds[i].userNotificationToken, category, tokenAndSounds[i].notificationSound, alertTitle, alertBody, customPayload);
    }
  }
  catch (error) {
    logServerError('sendNotificationForFamilyExcludingUser', error);
  }
}

module.exports = {
  sendNotificationForUser, sendNotificationForFamily, sendNotificationForFamilyExcludingUser,
};
