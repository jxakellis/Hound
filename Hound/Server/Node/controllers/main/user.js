const { ValidationError, convertErrorToJSON } = require('../../main/tools/general/errors');
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
      ? await getUserForUserId(req, userId)
    // user provided userIdentifier so we find them using that way
      : await getUserForUserIdentifier(req, userIdentifier);

    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
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
    const userId = await createUserForUserIdentifier(
      req,
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
    await req.commitQueries(req);

    refreshSecondaryAlarmNotificationsForUserId(userId, isFollowUpEnabled, followUpDelay);

    return res.status(200).json({ userId });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
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
      req,
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
    await req.commitQueries(req);

    refreshSecondaryAlarmNotificationsForUserId(userId, isFollowUpEnabled, followUpDelay);

    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getUser, createUser, updateUser,
};
