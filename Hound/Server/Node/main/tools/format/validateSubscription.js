const { ValidationError, convertErrorToJSON } = require('../general/errors');
const { areAllDefined } = require('./validateDefined');
const { getActiveSubscriptionForFamilyId } = require('../../../controllers/getFor/getForSubscription');
const { getAllFamilyMemberUserIdsForFamilyId } = require('../../../controllers/getFor/getForFamily');
const { getAllDogsForUserIdFamilyId } = require('../../../controllers/getFor/getForDogs');

/**
 * Checks the family's subscription
 * Uses getActiveSubscriptionForFamilyId to either get the family's paid subscription or the default free subscription
 * Attached the information to the req (under req.subscriptionInformation.xxx)
 */
const attachSubscriptionInformation = async (req, res, next) => {
  try {
    const familyId = req.params.familyId;

    // validate that a familyId was passed, assume that its in the correct format
    if (areAllDefined(req, familyId) === false) {
      throw new ValidationError('familyId missing', global.constant.error.value.MISSING);
    }

    const subscriptionInformation = await getActiveSubscriptionForFamilyId(req, familyId);

    req.subscriptionInformation = subscriptionInformation;

    return next();
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

/**
 * Checks the family's subscription to see if it's expired
 * If the request's method isn't GET or DELETE and the subscription is expired, returns 400 status
 */
const validateSubscription = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const familyId = req.params.familyId;
    const { subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs } = req.subscriptionInformation;

    if (areAllDefined(req, userId, familyId, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs) === false) {
      throw new ValidationError('req, userId, familyId, subscriptionNumberOfFamilyMembers, or subscriptionNumberOfDogs missing', global.constant.error.value.MISSING);
    }

    // a subscription doesn't matter for GET or DELETE requests. We can allow retrieving/deleting of information even if expired
    // We only deny POST or PUT requests if a expired subscription, stopping new information from being added
    if (req.method === 'GET' || req.method === 'DELETE') {
      return next();
    }

    const familyMembers = await getAllFamilyMemberUserIdsForFamilyId(req, familyId);

    if (familyMembers.length > subscriptionNumberOfFamilyMembers) {
      throw new ValidationError(`Family member limit of ${subscriptionNumberOfFamilyMembers} exceeded`, global.constant.error.family.limit.FAMILY_MEMBER_EXCEEDED);
    }

    const dogs = await getAllDogsForUserIdFamilyId(req, userId, familyId, undefined, false, false);

    if (dogs.length > subscriptionNumberOfDogs) {
      throw new ValidationError(`Dog limit of ${subscriptionNumberOfDogs} exceeded`, global.constant.error.family.limit.DOG_EXCEEDED);
    }

    return next();
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = { attachSubscriptionInformation, validateSubscription };
