const { getAllFamilyInformationForFamilyId } = require('../getFor/getForFamily');
const { createFamilyForUserId } = require('../createFor/createForFamily');
const { updateFamilyForUserIdFamilyId } = require('../updateFor/updateForFamily');
const { deleteFamilyForUserIdFamilyId } = require('../deleteFor/deleteForFamily');
/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) familyId formatted correctly and request has sufficient permissions to use
*/
async function getFamily(req, res) {
  try {
    const { familyId } = req.params;
    const result = await getAllFamilyInformationForFamilyId(req.connection, familyId, req.activeSubscription);
    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function createFamily(req, res) {
  try {
    const { userId } = req.params;
    const result = await createFamilyForUserId(req.connection, userId);
    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function updateFamily(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { familyCode, isLocked, isPaused } = req.body;
    await updateFamilyForUserIdFamilyId(req.connection, userId, familyId, familyCode, isLocked, isPaused);
    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function deleteFamily(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { kickUserId } = req.body;
    await deleteFamilyForUserIdFamilyId(req.connection, userId, familyId, kickUserId, req.activeSubscription);
    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = {
  getFamily, createFamily, updateFamily, deleteFamily,
};