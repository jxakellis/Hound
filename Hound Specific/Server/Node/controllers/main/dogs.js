const { getDogQuery, getDogsQuery } = require('../getFor/getForDogs');
const { createDogQuery } = require('../createFor/createForDogs');
const { updateDogQuery } = require('../updateFor/updateForDogs');
const { deleteDogQuery } = require('../deleteFor/deleteForDogs');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/

const getDogs = async (req, res) => {
  const familyId = req.params.familyId;
  const dogId = req.params.dogId;

  // if dogId is defined and it is a number then continue
  if (dogId) {
    try {
      const result = await getDogQuery(req, dogId);
      if (result.length === 0) {
        // successful but empty array, not dogs to return
        await req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there was a dog found, successful!
        await req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else {
    try {
      const result = await getDogsQuery(req, familyId);
      if (result.length === 0) {
        // successful but empty array, not dogs to return
        await req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there were dogs found, successful!
        await req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      // error when trying to do query to database
      await req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
};

const createDog = async (req, res) => {
  try {
    const result = await createDogQuery(req);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateDog = async (req, res) => {
  try {
    await updateDogQuery(req);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteDog = async (req, res) => {
  const dogId = req.params.dogId;
  try {
    await deleteDogQuery(req, req.params.userId, req.params.familyId, dogId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getDogs, createDog, updateDog, deleteDog,
};
