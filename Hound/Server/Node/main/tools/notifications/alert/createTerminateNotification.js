const { areAllDefined } = require('../../format/validateDefined');
const { sendAPNForUser } = require('../apn/sendAPN');

function createTerminateNotification(userId) {
  if (areAllDefined(userId) === false) {
    return;
  }
  // don't perform any checks as there are too many. we would have to make sure the user has notifications on, has loud notifications on, has an enabled/upcoming reminder, etc.
  sendAPNForUser(userId, global.constant.apn.category.TERMINATE, 'Oops, you may have terminated Hound!', "Your notifications won't ring properly if the app isn't running.", {});
}

module.exports = { createTerminateNotification };
