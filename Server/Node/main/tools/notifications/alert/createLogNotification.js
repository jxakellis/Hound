const { connectionForAlerts } = require('../../database/databaseConnections');
const { alertLogger } = require('../../logging/loggers');
const { areAllDefined } = require('../../format/validateDefined');

const { logServerError } = require('../../logging/logServerError');
const { getDogForDogId } = require('../../../../controllers/getFor/getForDogs');
const { getUserFirstNameLastNameForUserId } = require('../../../../controllers/getFor/getForUser');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');
const { formatLogAction } = require('../../format/formatName');

/**
 * Sends an alert to all of the family members that one of them has logged something.
 */
async function createLogNotification(userId, familyId, dogId, logAction, logCustomActionName) {
  try {
    alertLogger.debug(`createLogNotification ${userId}, ${familyId}, ${dogId}, ${logAction}, ${logCustomActionName}`);

    // make sure all params are defined
    if (areAllDefined(userId, familyId, dogId, logAction) === false) {
      return;
    }

    const user = await getUserFirstNameLastNameForUserId(connectionForAlerts, userId);

    let dog = await getDogForDogId(connectionForAlerts, dogId, undefined, undefined, undefined);
    [dog] = dog;

    // check to see if we were able to retrieve the properties of the user who logged the event and the dog that the log was under
    if (areAllDefined(user, user.userFirstName, user.userLastName, dog, dog.dogName) === false) {
      return;
    }

    const abreviatedFullName = formatIntoAbreviatedFullName(user.userFirstName, user.userLastName);
    const formattedLogAction = formatLogAction(logAction, logCustomActionName);

    // now we can construct the messages
    // Maxmium possible length: 8 (raw) + 32 (variable) = 40
    const alertTitle = `Log for ${dog.dogName}`;

    // Maxmium possible length: 28 (raw) + 34 (variable) + 32 (variable) = 94
    let alertBody = `${''} lent a helping hand with '${''}'`;
    const maximumLengthForFormattedLogAction = global.constant.apn.length.ALERT_BODY - alertBody.length;
    formattedLogAction.substring(0, maximumLengthForFormattedLogAction);

    alertBody = `${''} lent a helping hand with '${formattedLogAction}'`;

    const maximumLengthForAbreviatedFullName = global.constant.apn.length.ALERT_BODY - alertBody.length;
    abreviatedFullName.substring(0, maximumLengthForAbreviatedFullName);

    alertBody = `${abreviatedFullName} lent a helping hand with '${formattedLogAction}'`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.category.LOG, alertTitle, alertBody, {});
  }
  catch (error) {
    logServerError('createLogNotification', error);
  }
}

module.exports = { createLogNotification };
