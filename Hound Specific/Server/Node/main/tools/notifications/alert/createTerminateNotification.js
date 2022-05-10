const { areAllDefined } = require('../../validation/validateFormat');
const { sendAPNForUser } = require('../apn/sendAPN');

const createTerminateNotification = async (userId) => {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  sendAPNForUser(userId, 'terminate', 'Oops, you may have terminated Hound!', "Your notifications won't ring properly if the app isn't running.");
};

module.exports = { createTerminateNotification };
