/*
const DatabaseError = require('../errors/databaseError');
const ValidationError = require('../errors/validationError');
const GeneralError = require('../errors/generalError');
const { queryPromise } = require('../database/queryPromise');
const { formatDate, areAllDefined } = require('./formatObject');
const { DEFAULT_SUBSCRIPTION_TIER_ID } = require('../../server/constants');

const subscriptionTiersColumns = 'subscriptionTiers.tierNumberOfFamilyMembers, subscriptionTiers.tierNumberOfDogs';

/**
 *  Checks the family's subscription
 * If they have paid for a subscription, checks to see if its not expired
 * If they have a free subscription, bypasses expiration check
 * Attaches tierNumberOfFamilyMembers and tierNumberOfDogs to the req object
 */

/*
const validateFamilySubscription = async (req, res, next) => {
  const familyId = req.params.familyId;

  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('familyId missing', 'ER_VALUES_MISSING').toJSON);
  }

  let familySubscription;
  try {
    // find the tier's most recent subscription (the one with the lastest)
    familySubscription = await queryPromise(
      req,
      `SELECT ${subscriptionTiersColumns}, subscriptions.subscriptionExpiration FROM subscriptions JOIN subscriptionTiers ON subscriptions.tierId = subscriptionTiers.tierId WHERE familyId = ? ORDER BY subscriptions.subscriptionExpiration DESC LIMIT 1`,
      [familyId],
    );
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }

  // check to see if we located a familySubscription, if not, then we revert to the default
  if (familySubscription.length === 0) {
    console.log('no subscription found');
    try {
    // if the family has no subscription, assume that the family is using the default tier and load that info
      familySubscription = await queryPromise(
        req,
        'SELECT tierNumberOfFamilyMembers, tierNumberOfDogs FROM subscriptionTiers WHERE tierId = ? LIMIT 1',
        [DEFAULT_SUBSCRIPTION_TIER_ID],
      );
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  // we successfully found a subscription for the family. Check if that subscription is family has expired
  else {
    console.log(`subscription found ${familySubscription}`);
    const subscriptionExpiration = formatDate(familySubscription[0].subscriptionExpiration);

    if (areAllDefined(subscriptionExpiration) === false) {
      await req.rollbackQueries(req);
      return res.status(400).json(new GeneralError("Couldn't load your family's subscription", 'ER_NOT_FOUND').toJSON);
    }

    // TO DO handle downgrading paid subscription to free subscription. free subscription doesn't add any extries so if there are any paid subscription entires, then this will always trigger
    // if the current date is more in the future than the subscriptionExpiration, that means the subscription has expired
    if (new Date() > subscriptionExpiration) {
      await req.rollbackQueries(req);
      return res.status(400).json(new ValidationError('Family subscription has expired', 'ER_FAMILY_SUBSCRIPTION_EXPIRED').toJSON);
    }
  }

  // in theory, if the familySubscription.length === 0, then the above code should have loaded the defaultSubscription
  // If the familySubscription is still length 0, then we were unable to load both the family's subscription and the default subscription
  if (familySubscription.length === 0) {
    await req.rollbackQueries(req);
    return res.status(400).json(new GeneralError("Couldn't load your family's subscription", 'ER_NOT_FOUND').toJSON);
  }

  familySubscription = familySubscription[0];
  req.tierNumberOfFamilyMembers = familySubscription.tierNumberOfFamilyMembers;
  req.tierNumberOfDogs = familySubscription.tierNumberOfDogs;
  console.log(req.tierNumberOfFamilyMembers);
  console.log(req.tierNumberOfDogs);
  return next();
};

module.exports = { validateFamilySubscription };

*/
