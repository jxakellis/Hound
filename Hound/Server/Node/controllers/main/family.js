const { getAllFamilyInformationForFamilyId } = require('../getFor/getForFamily');
const { createFamilyForUserId } = require('../createFor/createForFamily');
const { updateFamilyForUserIdFamilyId } = require('../updateFor/updateForFamily');
const { deleteFamilyForUserIdFamilyId } = require('../deleteFor/deleteForFamily');
const { convertErrorToJSON } = require('../../main/tools/general/errors');
/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) familyId formatted correctly and request has sufficient permissions to use
*/
async function getFamily(req, res) {
  try {
    const { familyId } = req.params;
    const result = await getAllFamilyInformationForFamilyId(req, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function createFamily(req, res) {
  try {
    const { userId } = req.params;
    const result = await createFamilyForUserId(req, userId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    // create family failed
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function updateFamily(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { familyCode, isLocked, isPaused } = req.body;
    await updateFamilyForUserIdFamilyId(req, userId, familyId, familyCode, isLocked, isPaused);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function deleteFamily(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { kickUserId } = req.body;
    await deleteFamilyForUserIdFamilyId(req, userId, familyId, kickUserId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getFamily, createFamily, updateFamily, deleteFamily,
};
