const { areAllDefined } = require('../../format/validateDefined');
const { sendAPNForUser } = require('../apn/sendAPN');

function createTerminateNotification(userId) {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  // Maxmium possible length: 27 (raw) + 0 (variable) = 27
  const alertTitle = 'Oops, you terminated Hound!';
  // Maxmium possible length: 64 (raw) + 0 (variable) = 64
  const alertBody = "Your upcoming alarms won't ring properly if Hound isn't running.";
  sendAPNForUser(userId, global.constant.apn.category.TERMINATE, alertTitle, alertBody, {});
}

module.exports = { createTerminateNotification };