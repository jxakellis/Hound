const { formatNumber } = require('../../utils/validateFormat');

const { getFamilyForFamilyIdQuery, getFamilyForUserIdQuery } = require('../getFor/getForFamily');
const { createFamilyQuery } = require('../createFor/createForFamily');
const { updateFamilyQuery } = require('../updateFor/updateForFamily');
const { deleteFamilyQuery } = require('../deleteFor/deleteForFamily');
const convertErrorToJSON = require('../../utils/errors/errorFormat');
/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) familyId formatted correctly and request has sufficient permissions to use
*/
const getFamily = async (req, res) => {
  const userId = formatNumber(req.params.userId);
  const familyId = formatNumber(req.params.familyId);

  if (familyId) {
    try {
      const result = await getFamilyForFamilyIdQuery(req, familyId);
      if (result.length === 0) {
        // successful but empty array, not family members to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there was family members found, successful!
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
      const result = await getFamilyForUserIdQuery(req, userId);
      if (result.length === 0) {
        // successful but empty array, not family members to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there was family members found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
};

const createFamily = async (req, res) => {
  try {
    // attempt to create family
    const result = await createFamilyQuery(req);
    // create family succeeded
    req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    // create family failed
    req.rollbackQueries(req);
    return res.status(200).json(convertErrorToJSON(error));
  }
};

const updateFamily = async (req, res) => {
  // TO DO need complicated system to let someone join a family
  try {
    await updateFamilyQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteFamily = async (req, res) => {
  try {
    await deleteFamilyQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getFamily, createFamily, updateFamily, deleteFamily,
};
