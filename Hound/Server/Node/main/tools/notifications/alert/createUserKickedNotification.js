const { areAllDefined } = require('../../format/validateDefined');
const { sendAPNForUser } = require('../apn/sendAPN');

function createUserKickedNotification(userId) {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  sendAPNForUser(userId, global.constant.apn.GENERAL_CATEGORY, 'You have been kicked', 'You are no longer a part of your Hound family. However, you can still create or join another family', {});
}

module.exports = { createUserKickedNotification };
