const { connectionForLogs } = require('../../database/databaseConnection');
const { alertLogger } = require('../../logging/loggers');
const { areAllDefined } = require('../../validation/validateFormat');

const { queryPromise } = require('../../database/queryPromise');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { validateAbreviatedFullName } = require('../../validation/validateName');

/**
 * Sends an alert to all of the family members that one of them has logged something.
 */
const createLogNotification = async (userId, familyId, dogId, logAction, logCustomActionName) => {
  alertLogger.debug(`createLogNotification ${userId}, ${familyId}, ${dogId}, ${logAction}, ${logCustomActionName}`);
  // make sure all params are defined
  if (areAllDefined(userId, familyId, dogId, logAction) === false) {
    return;
  }

  try {
    // get the first and last name of the user who logged the event
    let user = await queryPromise(
      connectionForLogs,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );
    user = user[0];

    // get the name of the dog who got logged
    let dog = await queryPromise(
      connectionForLogs,
      'SELECT dogName FROM dogs WHERE dogId = ? LIMIT 1',
      [dogId],
    );
    dog = dog[0];

    // check to see if we were able to retrieve the properties of the user who logged the event and the dog that the log was under
    if (areAllDefined(user, dog, dog.dogName) === false) {
      return;
    }

    // now we can construct the messages
    // Log for Fido
    const alertTitle = `Log for ${dog.dogName}`;
    const name = validateAbreviatedFullName(user.userFirstName, user.userLastName);
    let alertBody;
    if (logAction === 'Custom' && areAllDefined(logCustomActionName)) {
      // Bob S lent a helping hand with 'Special Name'
      alertBody = `${name} lent a helping hand with '${logCustomActionName}'`;
    }
    else {
      // Bob S lent a helping hand with 'Potty: Poo'
      alertBody = `${name} lent a helping hand with '${logAction}'`;
    }

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, 'log', alertTitle, alertBody);
  }
  catch (error) {
    alertLogger.error('createLogNotification error:');
    alertLogger.error(error);
  }
};

module.exports = { createLogNotification };
