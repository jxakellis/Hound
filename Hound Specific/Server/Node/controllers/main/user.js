const ValidationError = require('../../main/tools/errors/validationError');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { getUserForUserId, getUserForUserIdentifier } = require('../getFor/getForUser');
const { createUserForUserIdentifier } = require('../createFor/createForUser');
const { updateUserForUserId } = require('../updateFor/updateForUser');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

// TO DO put all get, create, update, and deletes code inside their respective try catch statements
const getUser = async (req, res) => {
  // apple userIdentifier
  const userIdentifier = req.query.userIdentifier;
  // hound userId
  const userId = req.params.userId;
  let result;
  // user provided userId so we go that route
  if (areAllDefined(userId)) {
    try {
      result = await getUserForUserId(req, userId);
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  // user provided userIdentifier so we find them using that way
  else if (areAllDefined(userIdentifier)) {
    try {
      result = await getUserForUserIdentifier(req, userIdentifier);
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  // no identifier provided
  else {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userId or userIdentifier missing', 'ER_VALUES_MISSING').toJSON);
  }

  await req.commitQueries(req);
  return res.status(200).json({ result });
};

const { refreshSecondaryAlarmNotificationsForUserId } = require('../../main/tools/notifications/alarm/refreshAlarmNotification');

const createUser = async (req, res) => {
  try {
    const userIdentifier = req.body.userIdentifier;
    const result = await createUserForUserIdentifier(req, userIdentifier);
    await req.commitQueries(req);

    refreshSecondaryAlarmNotificationsForUserId(req.params.userId, req.body.isFollowUpEnabled, req.body.followUpDelay);

    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateUser = async (req, res) => {
  try {
    const userId = req.params.userId;
    await updateUserForUserId(req, userId);
    await req.commitQueries(req);

    refreshSecondaryAlarmNotificationsForUserId(req.params.userId, req.body.isFollowUpEnabled, req.body.followUpDelay);

    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getUser, createUser, updateUser,
};
