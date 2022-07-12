const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

// familyId, userId, subscriptionLastModified
const subscriptionColumns = 'transactionId, productId, subscriptionPurchaseDate, subscriptionExpiration, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs';

/**
 *  If the query is successful, returns the most recent subscription for the familyId (if no most recent subscription, fills in default subscription details).
 *  If a problem is encountered, creates and throws custom error
 */
const getActiveSubscriptionForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('familyId missing', global.constant.error.value.MISSING);
  }

  // find the family's most recent subscription
  // If it doesn't exist or its more expired than the SUBSCRIPTION_GRACE_PERIOD allows for, we get no result.

  const currentDate = new Date();
  // If we subtract the SUBSCRIPTION_GRACE_PERIOD from currentDate, we get a date that is that amount of time in the past. E.g. currentDate: 6:00 PM, gracePeriod: 1:00 -> currentDate: 5:00PM
  // Therefore when currentDate is compared to subscriptionExpiration, we allow for the subscriptionExpiration to be SUBSCRIPTION_GRACE_PERIOD amount of time expired.
  // This effect could also be achieved by adding SUBSCRIPTION_GRACE_PERIOD to subscriptionExpiration, making it appear to expire later than it actually does.
  currentDate.setTime(currentDate.getTime() - global.constant.subscription.SUBSCRIPTION_GRACE_PERIOD);

  let familySubscription = await databaseQuery(
    req,
    `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? AND subscriptionExpiration >= ? ORDER BY subscriptionExpiration DESC, subscriptionPurchaseDate DESC LIMIT 1`,
    [familyId, currentDate],
  );

  // since we found no family subscription, assign the family to the default subscription
  if (familySubscription.length === 0) {
    familySubscription = global.constant.subscription.SUBSCRIPTIONS.find((subscription) => subscription.productId === global.constant.subscription.DEFAULT_SUBSCRIPTION_PRODUCT_ID);
    familySubscription.transactionId = undefined;
    familySubscription.subscriptionPurchaseDate = undefined;
    familySubscription.subscriptionExpiration = new Date('3000-01-01T00:00:00Z');
  }
  else {
    // we found a subscription, so get rid of the one entry array
    familySubscription = familySubscription[0];
  }

  return familySubscription;
};

/**
 *  If the query is successful, returns the subscription history and active subscription for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getAllSubscriptionsForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('familyId missing', global.constant.error.value.MISSING);
  }

  // TO DO implement lastSubscriptionSyncronization properly for this so we only sync new subscriptions that the user doesn't have stored

  // find all of the family's subscriptions
  const subscriptionHistory = await databaseQuery(
    req,
    `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? ORDER BY subscriptionPurchaseDate DESC LIMIT 18446744073709551615`,
    [familyId],
  );

  const subscriptionActive = await getActiveSubscriptionForFamilyId(req, familyId);

  const result = {
    subscriptionActive,
    subscriptionHistory,
  };

  return result;
};

module.exports = { getActiveSubscriptionForFamilyId, getAllSubscriptionsForFamilyId };
