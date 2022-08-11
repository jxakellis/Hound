const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

// transactionId, familyId, and subscriptionLastModified omitted
const subscriptionColumns = 'transactionId, productId, userId, subscriptionPurchaseDate, subscriptionExpiration, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs';

/**
 *  If the query is successful, returns the most recent subscription for the familyId (if no most recent subscription, fills in default subscription details).
 *  If a problem is encountered, creates and throws custom error
 */
async function getActiveSubscriptionForFamilyId(databaseConnection, familyId) {
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // find the family's most recent subscription
  // If it doesn't exist or its more expired than the SUBSCRIPTION_GRACE_PERIOD allows for, we get no result.

  const currentDate = new Date();
  // If we subtract the SUBSCRIPTION_GRACE_PERIOD from currentDate, we get a date that is that amount of time in the past. E.g. currentDate: 6:00 PM, gracePeriod: 1:00 -> currentDate: 5:00PM
  // Therefore when currentDate is compared to subscriptionExpiration, we allow for the subscriptionExpiration to be SUBSCRIPTION_GRACE_PERIOD amount of time expired.
  // This effect could also be achieved by adding SUBSCRIPTION_GRACE_PERIOD to subscriptionExpiration, making it appear to expire later than it actually does.
  currentDate.setTime(currentDate.getTime() - global.constant.subscription.SUBSCRIPTION_GRACE_PERIOD);

  let familySubscription = await databaseQuery(
    databaseConnection,
    `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? AND subscriptionExpiration >= ? ORDER BY subscriptionExpiration DESC, subscriptionPurchaseDate DESC LIMIT 1`,
    [familyId, currentDate],
  );

  // since we found no family subscription, assign the family to the default subscription
  if (familySubscription.length === 0) {
    familySubscription = global.constant.subscription.SUBSCRIPTIONS.find((subscription) => subscription.productId === global.constant.subscription.DEFAULT_SUBSCRIPTION_PRODUCT_ID);
    familySubscription.userId = undefined;
    familySubscription.subscriptionPurchaseDate = undefined;
    familySubscription.subscriptionExpiration = undefined;
  }
  else {
    // we found a subscription, so get rid of the one entry array
    [familySubscription] = familySubscription;
  }

  familySubscription.subscriptionIsActive = true;

  return familySubscription;
}

/**
 *  If the query is successful, returns the subscription history and active subscription for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getAllSubscriptionsForFamilyId(databaseConnection, familyId) {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // find all of the family's subscriptions
  const subscriptionHistory = await databaseQuery(
    databaseConnection,
    `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? ORDER BY subscriptionExpiration DESC, subscriptionPurchaseDate DESC LIMIT 18446744073709551615`,
    [familyId],
  );

  // Don't use .activeSubscription property: Want to make sure this function always returns the most updated/accurate information
  const subscriptionActive = await getActiveSubscriptionForFamilyId(databaseConnection, familyId);

  for (let i = 0; i < subscriptionHistory.length; i += 1) {
    const subscription = subscriptionHistory[i];
    subscription.subscriptionIsActive = subscription.transactionId === subscriptionActive.transactionId;
  }

  return subscriptionHistory;
}

module.exports = { getActiveSubscriptionForFamilyId, getAllSubscriptionsForFamilyId };
