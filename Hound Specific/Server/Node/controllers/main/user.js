const ValidationError = require('../../main/tools/errors/validationError');
const {
  formatBoolean, formatNumber, atLeastOneDefined, areAllDefined,
} = require('../../main/tools/validation/validateFormat');

const { getUserForUserIdQuery, getUserForUserIdentifierQuery } = require('../getFor/getForUser');
const { createUserQuery } = require('../createFor/createForUser');
const { updateUserQuery } = require('../updateFor/updateForUser');
const { deleteUserQuery } = require('../deleteFor/deleteForUser');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {
  // apple userIdentifier
  const userIdentifier = req.query.userIdentifier;
  // hound userId
  const userId = req.params.userId;
  if (userId) {
    try {
      const result = await getUserForUserIdQuery(req, userId);
      await req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else if (areAllDefined(userIdentifier)) {
    try {
      const result = await getUserForUserIdentifierQuery(req, userIdentifier);
      await req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userId and  userIdentifier missing', 'ER_VALUES_MISSING').toJSON);
  }
};

const createUser = async (req, res) => {
  try {
    const result = await createUserQuery(req);
    await req.commitQueries(req);

    // both parameters should be defined. Therefore, we can create the follow up notifications for the user
    const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
    const followUpDelay = formatNumber(req.body.followUpDelay);
    if (areAllDefined([isFollowUpEnabled, followUpDelay])) {
      refreshSecondaryAlarmNotificationsForUser(req.params.userId, isFollowUpEnabled, followUpDelay);
    }

    return res.status(200).json({ result });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const { refreshSecondaryAlarmNotificationsForUser } = require('../../main/tools/notifications/alarm/refreshAlarmNotification');

const updateUser = async (req, res) => {
  try {
    await updateUserQuery(req);
    await req.commitQueries(req);

    const isFollowUpEnabled = formatBoolean(req.body.isFollowUpEnabled);
    const followUpDelay = formatNumber(req.body.followUpDelay);
    // check to see if either of these parameters are defined. If they are, then it means the user has updated them
    if (atLeastOneDefined([isFollowUpEnabled, followUpDelay])) {
      refreshSecondaryAlarmNotificationsForUser(req.params.userId, isFollowUpEnabled, followUpDelay);
    }

    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteUser = async (req, res) => {
  const userId = req.params.userId;
  const familyId = req.params.familyId;
  try {
    await deleteUserQuery(req, userId, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getUser, createUser, updateUser, deleteUser,
};
