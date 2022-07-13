const { ValidationError } = require('../../main/tools/general/errors');
const { atLeastOneDefined, areAllDefined } = require('../../main/tools/format/validateDefined');

const { getUserForUserId, getUserForUserIdentifier } = require('../getFor/getForUser');
const { createUserForUserIdentifier } = require('../createFor/createForUser');
const { updateUserForUserId } = require('../updateFor/updateForUser');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

async function getUser(req, res) {
  try {
    // hound userId
    const { userId } = req.params;
    // apple userIdentifier
    const { userIdentifier } = req.query;

    if (atLeastOneDefined(userId, userIdentifier) === false) {
      throw new ValidationError('userId or userIdentifier missing', global.constant.error.value.MISSING);
    }

    const result = areAllDefined(userId)
    // user provided userId so we go that route
      ? await getUserForUserId(req.connection, userId)
    // user provided userIdentifier so we find them using that way
      : await getUserForUserIdentifier(req.connection, userIdentifier);

    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

const { refreshSecondaryAlarmNotificationsForUserId } = require('../../main/tools/notifications/alarm/refreshAlarmNotification');

async function createUser(req, res) {
  try {
    const {
      userIdentifier,
      userEmail,
      userFirstName,
      userLastName,
      userNotificationToken,
      isNotificationEnabled,
      isLoudNotification,
      isFollowUpEnabled,
      followUpDelay,
      snoozeLength,
      notificationSound,
      interfaceStyle,
      logsInterfaceScale,
      remindersInterfaceScale,
    } = req.body;
    const result = await createUserForUserIdentifier(
      req.connection,
      userIdentifier,
      userEmail,
      userFirstName,
      userLastName,
      userNotificationToken,
      isNotificationEnabled,
      isLoudNotification,
      isFollowUpEnabled,
      followUpDelay,
      snoozeLength,
      notificationSound,
      interfaceStyle,
      logsInterfaceScale,
      remindersInterfaceScale,
    );

    refreshSecondaryAlarmNotificationsForUserId(result, isFollowUpEnabled, followUpDelay);

    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function updateUser(req, res) {
  try {
    const { userId } = req.params;
    const {
      userNotificationToken,
      isNotificationEnabled,
      isLoudNotification,
      isFollowUpEnabled,
      followUpDelay,
      snoozeLength,
      notificationSound,
      interfaceStyle,
      logsInterfaceScale,
      remindersInterfaceScale,
    } = req.body;
    await updateUserForUserId(
      req.connection,
      userId,
      userNotificationToken,
      isNotificationEnabled,
      isLoudNotification,
      isFollowUpEnabled,
      followUpDelay,
      snoozeLength,
      notificationSound,
      interfaceStyle,
      logsInterfaceScale,
      remindersInterfaceScale,
    );

    refreshSecondaryAlarmNotificationsForUserId(userId, isFollowUpEnabled, followUpDelay);

    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = {
  getUser, createUser, updateUser,
};
