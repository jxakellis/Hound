const DatabaseError = require('../errors/databaseError');
const ValidationError = require('../errors/validationError');
const { formatDate } = require('./formatObject');
const { areAllDefined } = require('./validateDefined');
const { getActiveSubscriptionForFamilyId } = require('../../../controllers/getFor/getForSubscription');

/**
 * Checks the family's subscription
 * Uses getActiveSubscriptionForFamilyId to either get the family's paid subscription or the default free subscription
 * Attached the information to the req (under req.subscriptionInformation.xxx)
 */
const attachSubscriptionInformation = async (req, res, next) => {
  const familyId = req.params.familyId;

  // validate that a familyId was passed, assume that its in the correct format
  if (areAllDefined(req, familyId) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('familyId missing', 'ER_VALUES_MISSING').toJSON);
  }

  try {
    const subscriptionInformation = await getActiveSubscriptionForFamilyId(req, familyId);

    // Attach the JSON response to the req for future reference
    /*
    subscriptionInformation: {
      productId: ___,
      subscriptionName: ___,
      subscriptionDescription: ___,
      subscriptionPurchaseDate: ___,
      subscriptionNumberOfFamilyMembers: ___,
      subscriptionNumberOfDogs: ___,
      subscriptionExpiration: ___,
    }
    */
    req.subscriptionInformation = subscriptionInformation;

    return next();
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

/**
 * Checks the family's subscription to see if it's expired. If the request is not a GET and the subscription is expired, returns 400 status
 */
const validateSubscription = async (req, res, next) => {
  const familyId = req.params.familyId;
  const subscriptionInformation = req.subscriptionInformation;

  if (areAllDefined(req, familyId, subscriptionInformation) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('familyId or subscriptionInformation missing', 'ER_VALUES_MISSING').toJSON);
  }

  // a subscription doesn't matter for GET requests. We can allow retrieving of information even if expired
  // We only deny POST, PUT, and DELETE requests if a expired subscription, freezing all information in place.
  if (req.method === 'GET') {
    return next();
  }

  // POST, PUT, or DELETE request, so we validate they still have an active subscription
  const subscriptionExpiration = formatDate(subscriptionInformation.subscriptionExpiration);

  if (areAllDefined(subscriptionExpiration) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('subscriptionExpiration missing', 'ER_VALUES_MISSING').toJSON);
  }

  // TO DO handle downgrading paid subscription to free subscription. free subscription doesn't add any extries so if there are any paid subscription entires, then this will always trigger

  // If the present is greater than the subscription expiration, then the family's subscription has expired
  if ((new Date()).getTime() > subscriptionExpiration.getTime()) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('Family subscription has expired', 'ER_FAMILY_SUBSCRIPTION_EXPIRED').toJSON);
  }

  return next();
};

module.exports = { attachSubscriptionInformation, validateSubscription };
