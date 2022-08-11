const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

async function createAppStoreServerNotificationForSignedPayload(signedPayload) {
  if (areAllDefined(signedPayload) === false) {
    throw new ValidationError('signedPayload missing', global.constant.error.value.MISSING);
  }
  const signedPayloadBuffer = Buffer.from(signedPayload.split('.')[1], 'base64');
  const notification = JSON.parse(signedPayloadBuffer.toString());

  if (areAllDefined(notification) === false) {
    throw new ValidationError('notification missing', global.constant.error.value.MISSING);
  }

  const {
    notificationType,
    subtype,
    notificationUUID,
    data,
    version,
    signedDate,
  } = notification;
  console.log('notification');
  console.log('notificationType', notificationType);
  console.log('subtype', subtype);
  console.log('notificationUUID', notificationUUID);
  console.log('version', version);
  console.log('signedDate', signedDate);

  if (areAllDefined(data) === false) {
    return;
  }

  const {
    appAppleId,
    bundleId,
    bundleVersion,
    environment,
    signedRenewalInfo,
    signedTransactionInfo,
  } = data;
  console.log('data');
  console.log('appAppleId', appAppleId);
  console.log('bundleId', bundleId);
  console.log('bundleVersion', bundleVersion);
  console.log('environment', environment);

  if (areAllDefined(signedRenewalInfo)) {
    const signedRenewalInfoBuffer = Buffer.from(signedRenewalInfo.split('.')[1], 'base64');
    const renewalInfo = JSON.parse(signedRenewalInfoBuffer.toString());

    getRenewalInfo(renewalInfo);
  }

  if (areAllDefined(signedTransactionInfo)) {
    const signedTransactionInfoBuffer = Buffer.from(signedTransactionInfo.split('.')[1], 'base64');
    const transactionInfo = JSON.parse(signedTransactionInfoBuffer.toString());

    getTransactionInfo(transactionInfo);
  }

  /*
  {
    // https://developer.apple.com/documentation/appstoreservernotifications/responsebodyv2decodedpayload
    // The in-app purchase event for which the App Store sent this version 2 notification.
    notificationType: SUBSCRIBED
    // Additional information that identifies the notification event, or an empty string. The subtype applies only to select version 2 notifications.
    subtype: RESUBSCRIBE
    // A unique identifier for the notification. Use this value to identify a duplicate notification.
    notificationUUID: 464a1798-529c-4484-8824-4ec224f71c53
    // A string that indicates the App Store Server Notification version number.
    version: 2.0
    // The UNIX time, in milliseconds, that the App Store signed the JSON Web Signature data.
    signedDate: 1660239552617
    data: {
      // https://developer.apple.com/documentation/appstoreservernotifications/data
      // The unique identifier of the app that the notification applies to. This property is available for apps that are downloaded from the App Store; it isn’t present in the sandbox environment.
      appAppleId: undefined
      // The bundle identifier of the app.
      bundleId: com.example.Pupotty
      // The version of the build that identifies an iteration of the bundle.
      bundleVersion: 4000
      // The server environment that the notification applies to, either sandbox or production.
      environment: Sandbox
      renewalInfo: {
        // https://developer.apple.com/documentation/appstoreservernotifications/jwsrenewalinfodecodedpayload
        // The product identifier of the product that renews at the next billing period.
        autoRenewProductId: 'com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly',
        // The renewal status for an auto-renewable subscription.
        autoRenewStatus: 1,
        // The server environment, either sandbox or production.
        environment: 'Sandbox',
        // The original transaction identifier of a purchase.
        originalTransactionId: '2000000106174332',
        // The product identifier of the in-app purchase.
        productId: 'com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly',
        // The earliest start date of an auto-renewable subscription in a series of subscription purchases that ignores all lapses of paid service that are 60 days or less.
        recentSubscriptionStartDate: 1660239031000
        // The UNIX time, in milliseconds, that the App Store signed the JSON Web Signature data.
        signedDate: 1660239552554,
      }
      transactionInfo: {
        // https://developer.apple.com/documentation/appstoreservernotifications/jwstransactiondecodedpayload
        // The bundle identifier of the app.
        bundleId: 'com.example.Pupotty',
        // The server environment, either sandbox or production.
        environment: 'Sandbox',
        // The UNIX time, in milliseconds, the subscription expires or renews.
        expiresDate: 1660239684000,
        // A string that describes whether the transaction was purchased by the user, or is available to them through Family Sharing.
        inAppOwnershipType: 'PURCHASED',
        // The UNIX time, in milliseconds, that represents the purchase date of the original transaction identifier.
        originalPurchaseDate: 1657848841000,
        // The transaction identifier of the original purchase.
        originalTransactionId: '2000000106174332',
        // The product identifier of the in-app purchase.
        productId: 'com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly',
        // The UNIX time, in milliseconds, that the App Store charged the user’s account for a purchase, restored product, subscription, or subscription renewal after a lapse.
        purchaseDate: 1660239504000,
        // The number of consumable products the user purchased.
        quantity: 1,
        // The UNIX time, in milliseconds, that the App Store signed the JSON Web Signature (JWS) data.
        signedDate: 1660239552575,
        // The identifier of the subscription group the subscription belongs to.
        subscriptionGroupIdentifier: '20965379',
        // The unique identifier of the transaction.
        transactionId: '2000000128308577',
        // The unique identifier of subscription purchase events across devices, including subscription renewals.
        type: 'Auto-Renewable Subscription',
        // The unique identifier of subscription purchase events across devices, including subscription renewals.
        webOrderLineItemId: '2000000009052985',
      }
    }
  }
  */
  // return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
}

function getRenewalInfo(renewalInfo) {
  if (areAllDefined(renewalInfo) === false) {
    return;
  }
  const {
    // https://developer.apple.com/documentation/appstoreservernotifications/jwsrenewalinfodecodedpayload
    // The product identifier of the product that renews at the next billing period.
    autoRenewProductId,
    // The renewal status for an auto-renewable subscription.
    autoRenewStatus,
    // The server environment, either sandbox or production.
    environment,
    // The reason a subscription expired.
    expirationIntent,
    // The time when the billing grace period for subscription renewals expires.
    gracePeriodExpiresDate,
    // The Boolean value that indicates whether the App Store is attempting to automatically renew an expired subscription.
    isInBillingRetryPeriod,
    // The offer code or the promotional offer identifier.
    offerIdentifier,
    // The type of subscription offer.
    offerType,
    // The original transaction identifier of a purchase.
    originalTransactionId,
    // The status that indicates whether the auto-renewable subscription is subject to a price increase.
    priceIncreaseStatus,
    // The product identifier of the in-app purchase.
    productId,
    // The earliest start date of an auto-renewable subscription in a series of subscription purchases that ignores all lapses of paid service that are 60 days or less.
    recentSubscriptionStartDate,
    // The UNIX time, in milliseconds, that the App Store signed the JSON Web Signature data.
    signedDate,
  } = renewalInfo;
  console.log('renewalInfo');
  console.log('autoRenewProductId', autoRenewProductId);
  console.log('autoRenewStatus', autoRenewStatus);
  console.log('environment', environment);
  console.log('expirationIntent', expirationIntent);
  console.log('gracePeriodExpiresDate', gracePeriodExpiresDate);
  console.log('isInBillingRetryPeriod', isInBillingRetryPeriod);
  console.log('offerIdentifier', offerIdentifier);
  console.log('offerType', offerType);
  console.log('originalTransactionId', originalTransactionId);
  console.log('priceIncreaseStatus', priceIncreaseStatus);
  console.log('productId', productId);
  console.log('recentSubscriptionStartDate', recentSubscriptionStartDate);
  console.log('signedDate', signedDate);
}

function getTransactionInfo(transactionInfo) {
  if (areAllDefined(transactionInfo) === false) {
    return;
  }
  const {
    // https://developer.apple.com/documentation/appstoreservernotifications/jwstransactiondecodedpayload
    // A UUID that associates the transaction with a user on your own service. If your app doesn’t provide an appAccountToken, this string is empty. For more information, see appAccountToken(_:).
    appAccountToken,
    // The bundle identifier of the app.
    bundleId,
    // The server environment, either sandbox or production.
    environment,
    // The UNIX time, in milliseconds, the subscription expires or renews.
    expiresDate,
    // A string that describes whether the transaction was purchased by the user, or is available to them through Family Sharing.
    inAppOwnershipType,
    // A Boolean value that indicates whether the user upgraded to another subscription.
    isUpgraded,
    // The identifier that contains the promo code or the promotional offer identifier.
    offerIdentifier,
    // A value that represents the promotional offer type.
    offerType,
    // The UNIX time, in milliseconds, that represents the purchase date of the original transaction identifier.
    originalPurchaseDate,
    // The transaction identifier of the original purchase.
    originalTransactionId,
    // The product identifier of the in-app purchase.
    productId,
    // The UNIX time, in milliseconds, that the App Store charged the user’s account for a purchase, restored product, subscription, or subscription renewal after a lapse.
    purchaseDate,
    // The number of consumable products the user purchased.
    quantity,
    // The UNIX time, in milliseconds, that the App Store refunded the transaction or revoked it from Family Sharing.
    revocationDate,
    // The reason that the App Store refunded the transaction or revoked it from Family Sharing.
    revocationReason,
    // The UNIX time, in milliseconds, that the App Store signed the JSON Web Signature (JWS) data.
    signedDate,
    // The identifier of the subscription group the subscription belongs to.
    subscriptionGroupIdentifier,
    // The unique identifier of the transaction.
    transactionId,
    // The unique identifier of subscription purchase events across devices, including subscription renewals.
    type,
    // The unique identifier of subscription purchase events across devices, including subscription renewals.
    webOrderLineItemId,
  } = transactionInfo;
  console.log('transactionInfo');
  console.log('appAccountToken', appAccountToken);
  console.log('bundleId', bundleId);
  console.log('environment', environment);
  console.log('expiresDate', expiresDate);
  console.log('inAppOwnershipType', inAppOwnershipType);
  console.log('isUpgraded', isUpgraded);
  console.log('offerIdentifier', offerIdentifier);
  console.log('offerIdentifier', offerType);
  console.log('originalPurchaseDate', originalPurchaseDate);
  console.log('originalTransactionId', originalTransactionId);
  console.log('productId', productId);
  console.log('purchaseDate', purchaseDate);
  console.log('quantity', quantity);
  console.log('revocationDate', revocationDate);
  console.log('revocationReason', revocationReason);
  console.log('signedDate', signedDate);
  console.log('subscriptionGroupIdentifier', subscriptionGroupIdentifier);
  console.log('transactionId', transactionId);
  console.log('type', type);
  console.log('webOrderLineItemId', webOrderLineItemId);
}

module.exports = {
  createAppStoreServerNotificationForSignedPayload,
};
