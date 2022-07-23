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

/*

TO DO NOW detect subscription refunds
To identify whether a subscription has been refunded, look for the cancellation_date field in the receipt.
The App Store notifies your server of refunds with a status update notification of type CANCEL, at which point you can handle the refund.
For example, if the user upgraded the subscription, immediately unlock service for the higher level subscription product purchased.

TO DO NOW detect subscription renewals
For this event, the App Store notifies your server with a notification of type RENEWAL
and a new receipt will be generated for the successful transaction.
You can look for a new value of the expires_date field to know the next renewal date of the subscription.

StoreKit adds a new transaction for the renewal to the transaction queue on the device.
Your app can check the transaction queue on launch and handle the renewal the same way as any other transaction.
If your app is already running when the subscription renews, the transaction observer is not called;
your app finds out about the renewal the next time the app launches.

TO DO FUTURE detect when a user cancels auto-renewal of their subscription
The user can also cancel their subscription by disabling auto-renew and intentionally letting their subscription lapse.
This action triggers the App Store to send your server a status update notification of type DID_CHANGE_RENEWAL_STATUS.
Your server can parse the auto_renew_status and the auto_renew_status_change_date to determine the current renewal status of the subscription.

You can also check the expiration_intent field in the receipt to further validate the reason for the subscription to lapse.
Make sure your app’s subscription logic can handle different values of expiration_intent along with expires_date to show the appropriate message to the user.

TO DO FUTURE detect plan changes for future renewals
You can check the receipt’s auto_renew_product_id field to learn
about any plan changes the user selected that will go into effect at the next renewal date.
*/

module.exports = {
  getSubscription, createSubscription,
};
