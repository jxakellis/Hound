const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const GeneralError = require('../../main/tools/errors/generalError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/formatObject');
const { DEFAULT_SUBSCRIPTION_TIER_ID } = require('../../main/server/constants');

/**
 *  If the query is successful, returns _____ for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getSubscriptionForFamilyId = async (req, familyId) => {
  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }

  let familySubscription;
  try {
    // find the tier's most recent subscription (the one with the lastest)
    familySubscription = await queryPromise(
      req,
      'SELECT subscriptionTiers.tierNumberOfFamilyMembers, subscriptionTiers.tierNumberOfDogs FROM subscriptions JOIN subscriptionTiers ON subscriptions.tierId = subscriptionTiers.tierId WHERE familyId = ? ORDER BY subscriptions.subscriptionExpiration DESC LIMIT 1',
      [familyId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  if (familySubscription.length === 0) {
    let defaultSubscription;
    try {
    // find the tier's most recent subscription (the one with the lastest)
      defaultSubscription = await queryPromise(
        req,
        'SELECT subscriptionTiers.tierNumberOfFamilyMembers, subscriptionTiers.tierNumberOfDogs FROM subscriptionTiers WHERE tierId = ? LIMIT 1',
        [DEFAULT_SUBSCRIPTION_TIER_ID],
      );
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }

    if (defaultSubscription.length === 0) {
      throw new GeneralError('Could not load default subscription', 'ER_NOT_FOUND');
    }

    return defaultSubscription[0];
  }

  return familySubscription[0];
};

module.exports = { getSubscriptionForFamilyId };
