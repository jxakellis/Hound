const { DatabaseError } = require('../errors/databaseError');
const { ValidationError } = require('../errors/validationError');
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

  // a subscription doesn't matter for GET or DELETE requests. We can allow retrieving/deleting of information even if expired
  // We only deny POST or PUT requests if a expired subscription, stopping new information from being added
  if (req.method === 'GET' || req.method === 'DELETE') {
    return next();
  }

  // POST or PUT request, so we validate they still have an active subscription
  const subscriptionExpiration = formatDate(subscriptionInformation.subscriptionExpiration);

  subscriptionExpiration.setTime(subscriptionExpiration.getTime() + global.constant.subscription.SUBSCRIPTION_GRACE_PERIOD);

  if (areAllDefined(subscriptionExpiration) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('subscriptionExpiration missing', 'ER_VALUES_MISSING').toJSON);
  }

  // TO DO if a family's subscription expires, it will downgrade to default eventually
  // this means that this validation statement will be passed, as the free subscription doesn't expire
  // therefore, instead of validation the subscription expiration, we must check to see if the family is currently exceeding their limits
  // e.g. if a family subscription expired and downgraded to default, they could have 2 family members and 3 dogs
  // we need reject POST and PUT statements from the users until the family is back within the default limits (1 FM & 2 dogs)
  // or upgrades their subscription again

  // If the present is greater than the subscription expiration, then the family's subscription has expired
  // The grace period is already factored into this. We use that when retrieving the subscription information under getForSubscription
  if ((new Date()).getTime() > subscriptionExpiration.getTime()) {
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('Family subscription has expired', 'ER_FAMILY_SUBSCRIPTION_EXPIRED').toJSON);
  }

  return next();
};

module.exports = { attachSubscriptionInformation, validateSubscription };
