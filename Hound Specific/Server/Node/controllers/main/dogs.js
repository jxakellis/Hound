const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');
const { formatNumber, areAllDefined, atLeastOneDefined } = require('../../utils/validateFormat');
const { getDogQuery, getDogsQuery } = require('../getFor/getForDogs');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/

const getDogs = async (req, res) => {
  const userId = formatNumber(req.params.userId);
  const dogId = formatNumber(req.params.dogId);

  // if dogId is defined and it is a number then continue
  if (dogId) {
    try {
      const result = await getDogQuery(req, dogId);
      if (result.length === 0) {
        // successful but empty array, not dogs to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there was a dog found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    try {
      const result = await getDogsQuery(req, userId);
      if (result.length === 0) {
        // successful but empty array, not dogs to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there were dogs found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      // error when trying to do query to database
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
};

const createDog = async (req, res) => {
  const userId = formatNumber(req.params.userId);
  const { dogName } = req.body;
  // const icon = req.body.icon

  if (areAllDefined([dogName]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('dogName missing', 'ER_VALUES_MISSING').toJSON);
  }

  // allow a user to have multiple dogs by the same dogName
  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogs(userId, icon, dogName) VALUES (?,?,?)',
      [userId, undefined, dogName],
    );
    req.commitQueries(req);
    return res.status(200).json({ result: result.insertId });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const updateDog = async (req, res) => {
  // could be updating dogName or icon

  const dogId = formatNumber(req.params.dogId);
  const { dogName } = req.body;
  const { icon } = req.body;

  // if dogName and icon are both undefined, then there is nothing to update
  if (atLeastOneDefined([dogName, icon]) === false) {
    req.commitQueries(req);
    return res.status(400).json(new ValidationError('No dogName or icon provided', 'ER_NO_VALUES_PROVIDED').toJSON);
  }

  try {
    if (dogName) {
      // updates the dogName for the dogId provided, overship of this dog for the user have been verifiied
      await queryPromise(req, 'UPDATE dogs SET dogName = ? WHERE dogId = ?', [dogName, dogId]);
    }
    if (icon) {
      // implement later
    }
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const delDog = require('../../utils/delete').deleteDog;

const deleteDog = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);

  try {
    await delDog(req, dogId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

module.exports = {
  getDogs, createDog, updateDog, deleteDog,
};
