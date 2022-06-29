const { getDogForDogId, getAllDogsForFamilyId } = require('../getFor/getForDogs');
const { createDogForFamilyId } = require('../createFor/createForDogs');
const { updateDogForDogId } = require('../updateFor/updateForDogs');
const { deleteDogForFamilyIdDogId } = require('../deleteFor/deleteForDogs');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/

// TO DO put all get, create, update, and deletes code inside their respective try catch statements
const getDogs = async (req, res) => {
  const familyId = req.params.familyId;
  const dogId = req.params.dogId;

  let result;
  try {
    // if dogId is defined and it is a number then continue to find a single dog
    if (areAllDefined(dogId)) {
      result = await getDogForDogId(req, dogId);
    }
    // looking for multiple dogs
    else {
      result = await getAllDogsForFamilyId(req, familyId);
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
    const familyId = req.params.familyId;
    const result = await createDogForFamilyId(req, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateDog = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    await updateDogForDogId(req, dogId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteDog = async (req, res) => {
  const dogId = req.params.dogId;
  try {
    await deleteDogForFamilyIdDogId(req, req.params.familyId, dogId);
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
