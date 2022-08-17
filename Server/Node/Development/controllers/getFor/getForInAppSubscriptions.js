const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { formatNumber } = require('../../main/tools/format/formatObject');

// Omitted columns: originalTransactionId, userId, familyId, subscriptionGroupIdentifier, quantity, webOrderLineItemId, inAppOwnershipType
const transactionsColumns = 'transactionId, productId, purchaseDate, expirationDate, numberOfFamilyMembers, numberOfDogs, isAutoRenewing, isRevoked';

/**
 *  If the query is successful, returns the most recent subscription for the familyId (if no most recent subscription, fills in default subscription details).
 *  If a problem is encountered, creates and throws custom error
 */
async function getActiveInAppSubscriptionForFamilyId(databaseConnection, familyId) {
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // find the family's most recent subscription
  // If it doesn't exist or its more expired than the SUBSCRIPTION_GRACE_PERIOD allows for, we get no result.

  const currentDate = new Date();
  // If we subtract the SUBSCRIPTION_GRACE_PERIOD from currentDate, we get a date that is that amount of time in the past. E.g. currentDate: 6:00 PM, gracePeriod: 1:00 -> currentDate: 5:00PM
  // Therefore when currentDate is compared to expirationDate, we allow for the expirationDate to be SUBSCRIPTION_GRACE_PERIOD amount of time expired.
  // This effect could also be achieved by adding SUBSCRIPTION_GRACE_PERIOD to expirationDate, making it appear to expire later than it actually does.
  currentDate.setTime(currentDate.getTime() - global.constant.subscription.SUBSCRIPTION_GRACE_PERIOD);

  let familySubscription = await databaseQuery(
    databaseConnection,
    `SELECT ${transactionsColumns} FROM transactions WHERE familyId = ? AND expirationDate >= ? AND isRevoked = 0 ORDER BY expirationDate DESC, purchaseDate DESC, transactionId DESC LIMIT 1`,
    [familyId, currentDate],
  );

  // since we found no family subscription, assign the family to the default subscription
  if (familySubscription.length === 0) {
    familySubscription = global.constant.subscription.SUBSCRIPTIONS.find((subscription) => subscription.productId === global.constant.subscription.DEFAULT_SUBSCRIPTION_PRODUCT_ID);
    familySubscription.userId = undefined;
    familySubscription.purchaseDate = undefined;
    familySubscription.expirationDate = undefined;
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
async function getAllInAppSubscriptionsForFamilyId(databaseConnection, familyId) {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // find all of the family's subscriptions
  const transactionsHistory = await databaseQuery(
    databaseConnection,
    `SELECT ${transactionsColumns} FROM transactions WHERE familyId = ? ORDER BY expirationDate DESC, purchaseDate DESC LIMIT 18446744073709551615`,
    [familyId],
  );

  // Don't use .activeSubscription property: Want to make sure this function always returns the most updated/accurate information
  const activeSubscription = await getActiveInAppSubscriptionForFamilyId(databaseConnection, familyId);

  for (let i = 0; i < transactionsHistory.length; i += 1) {
    const subscription = transactionsHistory[i];
    subscription.subscriptionIsActive = subscription.transactionId === activeSubscription.transactionId;
  }

  return transactionsHistory;
}

/**
 *  If the query is successful, returns the transaction for the transactionId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getInAppSubscriptionForTransactionId(databaseConnection, forTransactionId) {
  const transactionId = formatNumber(forTransactionId);
  if (areAllDefined(databaseConnection, transactionId) === false) {
    throw new ValidationError('databaseConnection or transactionId missing', global.constant.error.value.MISSING);
  }

  const transactionsHistory = await databaseQuery(
    databaseConnection,
    `SELECT ${transactionsColumns} FROM transactions WHERE transactionId = ? LIMIT 1`,
    [transactionId],
  );

  return transactionsHistory[0];
}

module.exports = {
  getActiveInAppSubscriptionForFamilyId, getAllInAppSubscriptionsForFamilyId, getInAppSubscriptionForTransactionId,
};
