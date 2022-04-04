const { formatNumber } = require('../../utils/validateFormat');

const { getDogQuery, getDogsQuery } = require('../getFor/getForDogs');
const { createDogQuery } = require('../createFor/createForDogs');
const { updateDogQuery } = require('../updateFor/updateForDogs');
const { deleteDogQuery } = require('../deleteFor/deleteForDogs');
const convertErrorToJSON = require('../../utils/errors/errorFormat');
/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/

const getDogs = async (req, res) => {
  const familyId = formatNumber(req.params.familyId);
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
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else {
    try {
      const result = await getDogsQuery(req, familyId);
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
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
};

const createDog = async (req, res) => {
  try {
    const result = await createDogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateDog = async (req, res) => {
  try {
    await updateDogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteDog = async (req, res) => {
  try {
    await deleteDogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getDogs, createDog, updateDog, deleteDog,
};
