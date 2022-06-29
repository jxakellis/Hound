const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const {
  SUBSCRIPTION_GRACE_PERIOD,
  DEFAULT_SUBSCRIPTION_PRODUCT_ID,
  DEFAULT_SUBSCRIPTION_NAME,
  DEFAULT_SUBSCRIPTION_DESCRIPTION,
  DEFAULT_SUBSCRIPTION_PURCHASE_DATE,
  DEFAULT_SUBSCRIPTION_EXPIRATION,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
} = require('../../main/server/constants');

// receiptId, familyId, userId, subscriptionLastModified
const subscriptionColumns = 'productId, subscriptionName, subscriptionDescription, subscriptionPurchaseDate, subscriptionExpiration, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs';

/**
 *  If the query is successful, returns the most recent subscription for the familyId (if no most recent subscription, fills in default subscription details).
 *  If a problem is encountered, creates and throws custom error
 */
const getActiveSubscriptionForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }

  let familySubscription;
  try {
    // find the family's most recent subscription
    // If it doesn't exist or its more expired than the SUBSCRIPTION_GRACE_PERIOD allows for, we get no result.

    const currentDate = new Date();
    // If we subtract the SUBSCRIPTION_GRACE_PERIOD from currentDate, we get a date that is that amount of time in the past. E.g. currentDate: 6:00 PM, gracePeriod: 1:00 -> currentDate: 5:00PM
    // Therefore when currentDate is compared to subscriptionExpiration, we allow for the subscriptionExpiration to be SUBSCRIPTION_GRACE_PERIOD amount of time expired.
    // This effect could also be achieved by adding SUBSCRIPTION_GRACE_PERIOD to subscriptionExpiration, making it appear to expire later than it actually does.
    currentDate.setTime(currentDate.getTime() - SUBSCRIPTION_GRACE_PERIOD);

    familySubscription = await queryPromise(
      req,
      `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? AND subscriptionExpiration >= ? ORDER BY subscriptionExpiration DESC LIMIT 1`,
      [familyId, currentDate],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // since we found no family subscription, assign the family to the default subscription
  if (familySubscription.length === 0) {
    familySubscription = {
      productId: DEFAULT_SUBSCRIPTION_PRODUCT_ID,
      subscriptionName: DEFAULT_SUBSCRIPTION_NAME,
      subscriptionDescription: DEFAULT_SUBSCRIPTION_DESCRIPTION,
      subscriptionPurchaseDate: DEFAULT_SUBSCRIPTION_PURCHASE_DATE,
      subscriptionExpiration: DEFAULT_SUBSCRIPTION_EXPIRATION,
      subscriptionNumberOfFamilyMembers: DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
      subscriptionNumberOfDogs: DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
    };
  }
  else {
    // we found a subscription, so get rid of the one entry array
    familySubscription = familySubscription[0];
  }
  console.log(familySubscription.productId);
  console.log(familySubscription.subscriptionName);
  console.log(familySubscription.subscriptionDescription);
  console.log(familySubscription.subscriptionPurchaseDate);
  console.log(familySubscription.subscriptionNumberOfFamilyMembers);
  console.log(familySubscription.subscriptionNumberOfDogs);
  console.log(familySubscription.subscriptionExpiration);

  return familySubscription;
};

/**
 *  If the query is successful, returns all subscriptions for the familyId (if no most recent subscription, fills in default subscription details).
 *  If a problem is encountered, creates and throws custom error
 */
const getAllSubscriptionsForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }

  // TO DO implement last subscription sync property for this so we only sync new subscriptions
  let familySubscription;
  try {
    // find all of the family's subscriptions

    familySubscription = await queryPromise(
      req,
      `SELECT ${subscriptionColumns} FROM subscriptions WHERE familyId = ? ORDER BY subscriptionExpiration DESC LIMIT 18446744073709551615`,
      [familyId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // since we found no family subscription, assign the family to the default subscription
  if (familySubscription.length === 0) {
    // use a one item array as the output is expecting an array
    familySubscription = [{
      productId: DEFAULT_SUBSCRIPTION_PRODUCT_ID,
      subscriptionName: DEFAULT_SUBSCRIPTION_NAME,
      subscriptionDescription: DEFAULT_SUBSCRIPTION_DESCRIPTION,
      subscriptionPurchaseDate: DEFAULT_SUBSCRIPTION_PURCHASE_DATE,
      subscriptionExpiration: DEFAULT_SUBSCRIPTION_EXPIRATION,
      subscriptionNumberOfFamilyMembers: DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
      subscriptionNumberOfDogs: DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
    }];
  }
  console.log(familySubscription);

  return familySubscription;
};

module.exports = { getActiveSubscriptionForFamilyId, getAllSubscriptionsForFamilyId };
