const { createAppStoreServerNotificationForSignedPayload } = require('../createFor/createForAppStoreServerNotifications');

async function createAppStoreServerNotification(req, res) {
  try {
    const { signedPayload } = req.body;
    await createAppStoreServerNotificationForSignedPayload(signedPayload);
    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = { createAppStoreServerNotification };
