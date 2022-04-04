const ValidationError = require('../../utils/errors/validationError');
const {
  areAllDefined, formatNumber,
} = require('../../utils/validateFormat');

const { getUserForUserIdQuery, getUserForUserIdentifierQuery } = require('../getFor/getForUser');
const { createUserQuery } = require('../createFor/createForUser');
const { updateUserQuery } = require('../updateFor/updateForUser');
const { deleteUserQuery } = require('../deleteFor/deleteForUser');
const convertErrorToJSON = require('../../utils/errors/errorFormat');

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {
  // apple user identifier
  const userIdentifier = req.params.userId;
  // hound user id id
  const userId = formatNumber(req.params.userId);
  if (userId) {
    try {
      const result = await getUserForUserIdQuery(req, userId);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else if (areAllDefined(userIdentifier)) {
    try {
      const result = await getUserForUserIdentifierQuery(req, userIdentifier);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userId and  userIdentifier missing', 'ER_VALUES_MISSING').toJSON);
  }
};

const createUser = async (req, res) => {
  try {
    const result = await createUserQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateUser = async (req, res) => {
  try {
    await updateUserQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteUser = async (req, res) => {
  try {
    await deleteUserQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getUser, createUser, updateUser, deleteUser,
};
