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

/*
*****************************************
***** START EXAMPLE NOTIFICATION 1 ******
*****************************************

User bought a subscription

notification:
notificationType SUBSCRIBED
subtype RESUBSCRIBE
notificationUUID 668ba178-ca1e-4ca8-9202-130be9adf6e5
version 2.0
signedDate 1660256142106

data:
appAppleId undefined
bundleId com.example.Pupotty
bundleVersion 4000
environment Sandbox

renewalInfo:
autoRenewProductId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
autoRenewStatus 1
environment Sandbox
expirationIntent undefined
gracePeriodExpiresDate undefined
isInBillingRetryPeriod undefined
offerIdentifier undefined
offerType undefined
originalTransactionId 2000000106174332
priceIncreaseStatus undefined
productId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
recentSubscriptionStartDate 1660256131000
signedDate 1660256142046

transactionInfo:
appAccountToken undefined
bundleId com.example.Pupotty
environment Sandbox
expiresDate 1660256311000
inAppOwnershipType PURCHASED
isUpgraded undefined
offerIdentifier undefined
offerIdentifier undefined
originalPurchaseDate 1657848841000
originalTransactionId 2000000106174332
productId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
purchaseDate 1660256131000
quantity 1
revocationDate undefined
revocationReason undefined
signedDate 1660256142066
subscriptionGroupIdentifier 20965379
transactionId 2000000128395051
type Auto-Renewable Subscription
webOrderLineItemId 2000000009053141

*****************************************
****** END EXAMPLE NOTIFICATION 1 *******
*****************************************

*****************************************
***** START EXAMPLE NOTIFICATION 2 ******
*****************************************

User's subscription automatically renewed

notification:
notificationType DID_RENEW
subtype undefined
notificationUUID 6ff93340-62ae-4068-a482-1efd472be3c4
version 2.0
signedDate 1660256280157

data:
appAppleId undefined
bundleId com.example.Pupotty
bundleVersion 4000
environment Sandbox

renewalInfo:
autoRenewProductId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
autoRenewStatus 1
environment Sandbox
expirationIntent undefined
gracePeriodExpiresDate undefined
isInBillingRetryPeriod undefined
offerIdentifier undefined
offerType undefined
originalTransactionId 2000000106174332
priceIncreaseStatus undefined
productId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
recentSubscriptionStartDate 1660256131000
signedDate 1660256280095

transactionInfo:
appAccountToken undefined
bundleId com.example.Pupotty
environment Sandbox
expiresDate 1660256491000
inAppOwnershipType PURCHASED
isUpgraded undefined
offerIdentifier undefined
offerIdentifier undefined
originalPurchaseDate 1657848841000
originalTransactionId 2000000106174332
productId com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly
purchaseDate 1660256311000
quantity 1
revocationDate undefined
revocationReason undefined
signedDate 1660256280116
subscriptionGroupIdentifier 20965379
transactionId 2000000128395249
type Auto-Renewable Subscription
webOrderLineItemId 2000000009063693

*****************************************
****** END EXAMPLE NOTIFICATION 2 *******
*****************************************

*****************************************
***** START EXAMPLE NOTIFICATION 3 ******
*****************************************

notification:
notificationType DID_CHANGE_RENEWAL_STATUS
subtype AUTO_RENEW_DISABLED
notificationUUID b63cf655-d9b4-4b4e-9c27-237d6031160b
version 2.0
signedDate 1660589719742

data:
appAppleId undefined
bundleId com.example.Pupotty
bundleVersion 4000
environment Sandbox

renewalInfo:
autoRenewProductId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
autoRenewStatus 0
environment Sandbox
expirationIntent undefined
gracePeriodExpiresDate undefined
isInBillingRetryPeriod undefined
offerIdentifier undefined
offerType undefined
originalTransactionId 2000000106174332
priceIncreaseStatus undefined
productId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
recentSubscriptionStartDate 1660589668000
signedDate 1660589719510

transactionInfo:
appAccountToken undefined
bundleId com.example.Pupotty
environment Sandbox
expiresDate 1660589848000
inAppOwnershipType PURCHASED
isUpgraded undefined
offerIdentifier undefined
offerIdentifier undefined
originalPurchaseDate 1657848841000
originalTransactionId 2000000106174332
productId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
purchaseDate 1660589668000
quantity 1
revocationDate undefined
revocationReason undefined
signedDate 1660589719538
subscriptionGroupIdentifier 20965379
transactionId 2000000130393421
type Auto-Renewable Subscription
webOrderLineItemId 2000000009064713

*****************************************
****** END EXAMPLE NOTIFICATION 3 *******
*****************************************

*****************************************
***** START EXAMPLE NOTIFICATION 4 ******
*****************************************

notification:
notificationType DID_CHANGE_RENEWAL_STATUS
subtype AUTO_RENEW_ENABLED
notificationUUID bebf77d4-444a-4ea1-9bb6-8996f35c4a22
version 2.0
signedDate 1660589832025

data:
appAppleId undefined
bundleId com.example.Pupotty
bundleVersion 4000
environment Sandbox

renewalInfo:
autoRenewProductId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
autoRenewStatus 1
environment Sandbox
expirationIntent undefined
gracePeriodExpiresDate undefined
isInBillingRetryPeriod undefined
offerIdentifier undefined
offerType undefined
originalTransactionId 2000000106174332
priceIncreaseStatus undefined
productId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
recentSubscriptionStartDate 1660589668000
signedDate 1660589831967

transactionInfo:
appAccountToken undefined
bundleId com.example.Pupotty
environment Sandbox
expiresDate 1660589848000
inAppOwnershipType PURCHASED
isUpgraded undefined
offerIdentifier undefined
offerIdentifier undefined
originalPurchaseDate 1657848841000
originalTransactionId 2000000106174332
productId com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly
purchaseDate 1660589668000
quantity 1
revocationDate undefined
revocationReason undefined
signedDate 1660589831987
subscriptionGroupIdentifier 20965379
transactionId 2000000130393421
type Auto-Renewable Subscription
webOrderLineItemId 2000000009064713

*****************************************
****** END EXAMPLE NOTIFICATION 3 *******
*****************************************

*/
