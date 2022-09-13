const { areAllDefined } = require('../../format/validateDefined');
const { sendNotificationForUser } = require('../apn/sendNotification');

function createTerminateNotification(userId) {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  // Maximum possible length of message: 27 (raw) + 0 (variable) = 27 (<= ALERT_TITLE_LIMIT)
  const alertTitle = 'Oops, you terminated Hound!';
  // Maximum possible length of message: 64 (raw) + 0 (variable) = 64 (<= ALERT_BODY_LIMIT)
  const alertBody = "Your upcoming alarms won't ring properly if Hound isn't running.";
  sendNotificationForUser(userId, global.constant.notification.category.user.TERMINATE, alertTitle, alertBody, {});
}

module.exports = { createTerminateNotification };
