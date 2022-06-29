const { getAllSubscriptionsForFamilyId } = require('../getFor/getForSubscription');
const { createSubscriptionForUserIdFamilyIdRecieptId } = require('../createFor/createForSubscription');
const { formatBase64EncodedString } = require('../../main/tools/format/formatObject');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');

// TO DO put all get, create, update, and deletes code inside their respective try catch statements
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
    const encodedReceiptData = formatBase64EncodedString(req.params.encodedReceiptData);
    const result = createSubscriptionForUserIdFamilyIdRecieptId(req, userId, familyId, encodedReceiptData);
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
