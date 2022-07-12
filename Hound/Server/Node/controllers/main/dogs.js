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
async function getDogs(req, res) {
  try {
    const { userId, familyId, dogId } = req.params;
    const { lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs } = req.query;
    // if dogId is defined and it is a number then continue to find a single dog, otherwise, we are looking for all dogs
    const result = areAllDefined(dogId)
      ? await getDogForDogId(req, dogId, lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs)
      : await getAllDogsForUserIdFamilyId(req, userId, familyId, lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs);

    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function createDog(req, res) {
  try {
    const { familyId } = req.params;
    const { dogName } = req.body;
    const { subscriptionInformation } = req;
    const result = await createDogForFamilyId(req, familyId, subscriptionInformation, dogName);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function updateDog(req, res) {
  try {
    const { dogId } = req.params;
    const { dogName } = req.body;
    await updateDogForDogId(req, dogId, dogName);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function deleteDog(req, res) {
  try {
    const { familyId, dogId } = req.params;
    await deleteDogForFamilyIdDogId(req, familyId, dogId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getDogs, createDog, updateDog, deleteDog,
};
