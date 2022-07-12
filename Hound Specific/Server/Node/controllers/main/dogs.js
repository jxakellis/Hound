const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { getDogForDogId, getAllDogsForUserIdFamilyId } = require('../getFor/getForDogs');
const { createDogForFamilyId } = require('../createFor/createForDogs');
const { updateDogForDogId } = require('../updateFor/updateForDogs');
const { deleteDogForFamilyIdDogId } = require('../deleteFor/deleteForDogs');
const { convertErrorToJSON } = require('../../main/tools/general/errors');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/
const getDogs = async (req, res) => {
  try {
    const userId = req.params.userId;
    const familyId = req.params.familyId;
    const dogId = req.params.dogId;
    let result;
    // if dogId is defined and it is a number then continue to find a single dog
    if (areAllDefined(dogId)) {
      result = await getDogForDogId(req, dogId, req.query.lastDogManagerSynchronization, req.query.reminders, req.query.logs);
    }
    // looking for multiple dogs
    else {
      result = await getAllDogsForUserIdFamilyId(req, userId, familyId, req.query.lastDogManagerSynchronization, req.query.reminders, req.query.logs);
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
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
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
  try {
    const dogId = req.params.dogId;
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
