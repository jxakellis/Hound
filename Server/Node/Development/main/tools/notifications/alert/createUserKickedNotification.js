const { areAllDefined } = require('../../format/validateDefined');
const { sendNotificationForUser } = require('../apn/sendNotification');

function createUserKickedNotification(userId) {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  // Maxmium possible length: 20 (raw) + 0 (variable) = 20
  const alertTitle = 'You have been kicked';
  // Maxmium possible length: 99 (raw) + 0 (variable) = 99
  const alertBody = 'You are no longer a part of your Hound family. However, you can still create or join another family';
  sendNotificationForUser(userId, global.constant.apn.category.GENERAL, alertTitle, alertBody, {});
}

module.exports = { createUserKickedNotification };
