const { connectionForAlerts } = require('../../database/databaseConnections');
const { alertLogger } = require('../../logging/loggers');
const { areAllDefined } = require('../../format/validateDefined');

const { getDogForDogId } = require('../../../../controllers/getFor/getForDogs');
const { getUserFirstNameLastNameForUserId } = require('../../../../controllers/getFor/getForUser');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');
const { formatLogAction } = require('../../format/formatName');

/**
 * Sends an alert to all of the family members that one of them has logged something.
 */
const createLogNotification = async (userId, familyId, dogId, logAction, logCustomActionName) => {
  try {
    if (global.constant.server.IS_PRODUCTION === false) {
      alertLogger.debug(`createLogNotification ${userId}, ${familyId}, ${dogId}, ${logAction}, ${logCustomActionName}`);
    }

    // make sure all params are defined
    if (areAllDefined(userId, familyId, dogId, logAction) === false) {
      return;
    }

    const user = await getUserFirstNameLastNameForUserId(connectionForAlerts, userId);

    const dog = await getDogForDogId(connectionForAlerts, dogId, undefined, undefined, undefined);

    // check to see if we were able to retrieve the properties of the user who logged the event and the dog that the log was under
    if (areAllDefined(user, user.userFirstName, user.userLastName, dog, dog.dogName) === false) {
      return;
    }

    // now we can construct the messages
    // Log for Fido
    const alertTitle = `Log for ${dog.dogName}`;
    const name = formatIntoAbreviatedFullName(user.userFirstName, user.userLastName);
    const alertBody = `${name} lent a helping hand with '${formatLogAction(logAction, logCustomActionName)}'`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, global.constant.apn.LOG_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createLogNotification error:');
    alertLogger.error(error);
  }
};

module.exports = { createLogNotification };
