const { getAllSubscriptionsForFamilyId } = require('../getFor/getForSubscription');
const { createSubscriptionForUserIdFamilyIdRecieptId } = require('../createFor/createForSubscription');

async function getSubscription(req, res) {
  try {
    const { familyId } = req.params;
    const result = await getAllSubscriptionsForFamilyId(req.connection, familyId);
    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function createSubscription(req, res) {
  try {
    const { userId, familyId } = req.params;
    const { base64EncodedAppStoreReceiptURL } = req.body;
    const result = await createSubscriptionForUserIdFamilyIdRecieptId(req.connection, userId, familyId, base64EncodedAppStoreReceiptURL);
    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = {
  getSubscription, createSubscription,
};
