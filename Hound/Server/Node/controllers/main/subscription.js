const { getAllSubscriptionsForFamilyId } = require('../getFor/getForSubscription');
const { createSubscriptionForUserIdFamilyIdRecieptId } = require('../createFor/createForSubscription');
const { convertErrorToJSON } = require('../../main/tools/general/errors');

const getSubscription = async (req, res) => {
  try {
    const familyId = req.params.familyId;
    const result = await getAllSubscriptionsForFamilyId(req, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const createSubscription = async (req, res) => {
  try {
    const userId = req.params.userId;
    const familyId = req.params.familyId;
    const base64EncodedReceiptData = req.body.base64EncodedReceiptData;
    const result = await createSubscriptionForUserIdFamilyIdRecieptId(req, userId, familyId, base64EncodedReceiptData);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getSubscription, createSubscription,
};
