const { getAllFamilyInformationForFamilyId } = require('../getFor/getForFamily');
const { createFamilyForUserId } = require('../createFor/createForFamily');
const { updateFamilyForUserIdFamilyId } = require('../updateFor/updateForFamily');
const { deleteFamilyForUserIdFamilyId } = require('../deleteFor/deleteForFamily');
const { convertErrorToJSON } = require('../../main/tools/errors/errorFormat');
/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) familyId formatted correctly and request has sufficient permissions to use
*/
const getFamily = async (req, res) => {
  try {
    const familyId = req.params.familyId;
    const result = await getAllFamilyInformationForFamilyId(req, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const createFamily = async (req, res) => {
  try {
    const userId = req.params.userId;
    const result = await createFamilyForUserId(req, userId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    // create family failed
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateFamily = async (req, res) => {
  try {
    const userId = req.params.userId;
    const familyId = req.params.familyId;
    await updateFamilyForUserIdFamilyId(req, userId, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteFamily = async (req, res) => {
  try {
    const userId = req.params.userId;
    const familyId = req.params.familyId;
    await deleteFamilyForUserIdFamilyId(req, userId, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getFamily, createFamily, updateFamily, deleteFamily,
};
