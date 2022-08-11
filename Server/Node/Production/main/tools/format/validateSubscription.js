const { ValidationError } = require('../general/errors');
const { areAllDefined } = require('./validateDefined');
const { getActiveInAppSubscriptionForFamilyId } = require('../../../controllers/getFor/getForInAppSubscriptions');
const { getAllFamilyMembersForFamilyId } = require('../../../controllers/getFor/getForFamily');
const { databaseQuery } = require('../database/databaseQuery');

/**
 * Checks the family's subscription
 * Uses getActiveInAppSubscriptionForFamilyId to either get the family's paid subscription or the default free subscription
 * Attached the information to the req (under req.activeSubscription.xxx)
 */
async function attachActiveSubscription(req, res, next) {
  try {
    const { familyId } = req.params;

    // validate that a familyId was passed, assume that its in the correct format
    if (areAllDefined(familyId) === false) {
      throw new ValidationError('familyId missing', global.constant.error.value.MISSING);
    }

    const activeSubscription = await getActiveInAppSubscriptionForFamilyId(req.databaseConnection, familyId);

    req.activeSubscription = activeSubscription;

    return next();
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

/**
 * Checks the family's subscription to see if it's expired
 * If the request's method isn't GET or DELETE and the subscription is expired, returns 400 status
 */
async function validateSubscription(req, res, next) {
  try {
    const { userId, familyId } = req.params;
    const { subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs } = req.activeSubscription;

    if (areAllDefined(userId, familyId, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs) === false) {
      throw new ValidationError('userId, familyId, subscriptionNumberOfFamilyMembers, or subscriptionNumberOfDogs missing', global.constant.error.value.MISSING);
    }

    // a subscription doesn't matter for GET or DELETE requests. We can allow retrieving/deleting of information even if expired
    // We only deny POST or PUT requests if a expired subscription, stopping new information from being added
    if (req.method === 'GET' || req.method === 'DELETE') {
      return next();
    }

    const familyMembers = await getAllFamilyMembersForFamilyId(req.databaseConnection, familyId);

    if (familyMembers.length > subscriptionNumberOfFamilyMembers) {
      throw new ValidationError(`Family member limit of ${subscriptionNumberOfFamilyMembers} exceeded`, global.constant.error.family.limit.FAMILY_MEMBER_EXCEEDED);
    }

    // only retrieve enough not deleted dogs that would exceed the limit
    const dogs = await databaseQuery(
      req.databaseConnection,
      'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT ?',
      [familyId, subscriptionNumberOfDogs],
    );

    if (dogs.length > subscriptionNumberOfDogs) {
      throw new ValidationError(`Dog limit of ${subscriptionNumberOfDogs} exceeded`, global.constant.error.family.limit.DOG_EXCEEDED);
    }

    return next();
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = { attachActiveSubscription, validateSubscription };
