const { getDogQuery, getDogsQuery } = require('../getFor/getForDogs');
const { createDogQuery } = require('../createFor/createForDogs');
const { updateDogQuery } = require('../updateFor/updateForDogs');
const { deleteDogForDogId } = require('../deleteFor/deleteForDogs');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');
const { areAllDefined } = require('../../main/tools/format/formatObject');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/

const getDogs = async (req, res) => {
  const familyId = req.params.familyId;
  const dogId = req.params.dogId;

  let result;
  try {
    // if dogId is defined and it is a number then continue to find a single dog
    if (areAllDefined(dogId)) {
      result = await getDogQuery(req, dogId);
    }
    // looking for multiple dogs
    else {
      result = await getDogsQuery(req, familyId);
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }

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
    await deleteDogForDogId(req, req.params.familyId, dogId);
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
