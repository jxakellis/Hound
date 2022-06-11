const { connectionForAlerts } = require('../../database/databaseConnection');
const { alertLogger } = require('../../logging/loggers');
const { areAllDefined } = require('../../format/formatObject');

const { queryPromise } = require('../../database/queryPromise');
const { sendAPNForFamilyExcludingUser } = require('../apn/sendAPN');
const { formatIntoAbreviatedFullName } = require('../../format/formatName');
const { formatLogAction } = require('../../format/formatName');
const { LOG_CATEGORY, IS_PRODUCTION } = require('../../../server/constants');

/**
 * Sends an alert to all of the family members that one of them has logged something.
 */
const createLogNotification = async (userId, familyId, dogId, logAction, logCustomActionName) => {
  try {
    if (IS_PRODUCTION === false) {
      alertLogger.debug(`createLogNotification ${userId}, ${familyId}, ${dogId}, ${logAction}, ${logCustomActionName}`);
    }

    // make sure all params are defined
    if (areAllDefined(userId, familyId, dogId, logAction) === false) {
      return;
    }

    // get the first and last name of the user who logged the event
    let user = await queryPromise(
      connectionForAlerts,
      'SELECT userFirstName, userLastName FROM users WHERE userId = ? LIMIT 1',
      [userId],
    );
    user = user[0];

    // get the name of the dog who got logged
    let dog = await queryPromise(
      connectionForAlerts,
      'SELECT dogName FROM dogs WHERE dogIsDeleted = 0 AND dogId = ? LIMIT 1',
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
    const name = formatIntoAbreviatedFullName(user.userFirstName, user.userLastName);
    const alertBody = `${name} lent a helping hand with '${formatLogAction(logAction, logCustomActionName)}'`;

    // we now have the messages and can send our APN
    sendAPNForFamilyExcludingUser(userId, familyId, LOG_CATEGORY, alertTitle, alertBody, {});
  }
  catch (error) {
    alertLogger.error('createLogNotification error:');
    alertLogger.error(error);
  }
};

module.exports = { createLogNotification };
