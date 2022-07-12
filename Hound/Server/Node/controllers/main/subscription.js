const { getAllSubscriptionsForFamilyId } = require('../getFor/getForSubscription');
const { createSubscriptionForUserIdFamilyIdRecieptId } = require('../createFor/createForSubscription');
const { convertErrorToJSON } = require('../../main/tools/general/errors');

async function getSubscription(req, res) {
  try {
    const { familyId } = req.params;
    const result = await getAllSubscriptionsForFamilyId(req, familyId);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function createSubscription(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { base64EncodedAppStoreReceiptURL } = req.body;
    const result = await createSubscriptionForUserIdFamilyIdRecieptId(req, userId, familyId, base64EncodedAppStoreReceiptURL);
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getSubscription, createSubscription,
};
