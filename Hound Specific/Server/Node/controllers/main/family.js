const { getFamilyInformationForFamilyIdQuery } = require('../getFor/getForFamily');
const { createFamilyQuery } = require('../createFor/createForFamily');
const { updateFamilyQuery } = require('../updateFor/updateForFamily');
const { deleteFamilyQuery } = require('../deleteFor/deleteForFamily');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');
/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) familyId formatted correctly and request has sufficient permissions to use
*/
const getFamily = async (req, res) => {
  const familyId = req.params.familyId;
  try {
    const result = await getFamilyInformationForFamilyIdQuery(req, familyId);
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
    const result = await createFamilyQuery(req);
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
    await updateFamilyQuery(req);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteFamily = async (req, res) => {
  const userId = req.params.userId;
  const familyId = req.params.familyId;

  try {
    await deleteFamilyQuery(req, userId, familyId);
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
