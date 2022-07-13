const { databaseQuery } = require('../database/databaseQuery');
const { formatSHA256Hash, formatNumber, formatArray } = require('./formatObject');
const { areAllDefined } = require('./validateDefined');
const { ValidationError } = require('../general/errors');

/**
 * Checks to see that the appBuild of the requester is either up to date or one version behind.
 * If a Hound update is publish, we want to support both the users who have updated to the brand new version and the ones who haven't.
 * If we didn't support both, then users could be locked out of Hound and unable to update as the app store takes a day or two to show the update
 *
 * However, if a user is on an old version, we kick them back.
 * E.g. User is on build 1000. The most recent build was 1500 but we just published 2000.
 * We reject the build 1000 user but support build 1500 and build 2000.
 * Build 1500 will no longer be supported once a new build (e.g. 2500) comes out.
 */
async function validateAppBuild(req, res, next) {
  const appBuild = formatNumber(req.params.appBuild);
  if (areAllDefined(appBuild) === false) {
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('appBuild missing', global.constant.error.value.MISSING));
  }
  // the user isn't on the previous or current app build
  if (appBuild !== global.constant.server.PREVIOUS_APP_BUILD && appBuild !== global.constant.server.CURRENT_APP_BUILD) {
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError(`appBuild of ${appBuild} is invalid. Acceptable builds are ${global.constant.server.PREVIOUS_APP_BUILD} and ${global.constant.server.CURRENT_APP_BUILD}`, global.constant.error.general.APP_BUILD_OUTDATED));
  }

  return next();
}

/**
 * Checks to see that userId and userIdentifier are defined, are valid, and exist in the database.
 */
async function validateUserId(req, res, next) {
  // later on use a token here to validate that they have permission to use the userId

  const userId = formatSHA256Hash(req.params.userId);
  const userIdentifier = formatSHA256Hash(req.query.userIdentifier);

  if (areAllDefined(userIdentifier, userId) === false) {
    // userId was not provided or is invalid format OR userIdentifier was not provided or is invalid format
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('userId or userIdentifier Invalid', global.constant.error.value.INVALID));
  }

  // if userId is defined and it is a number then continue
  try {
    // queries the database to find if the users table contains a user with the provided ID
    const result = await databaseQuery(
      req.connection,
      'SELECT userId FROM users WHERE userId = ? AND userIdentifier = ? LIMIT 1',
      [userId, userIdentifier],
    );

    if (result.length === 0) {
      // userId does not exist in the table
      return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No user found or invalid permissions', global.constant.error.value.INVALID));
    }

    // userId exists in the table for given userId and identifier, so all valid
    // reassign req.params so that the id there is guarrenteed to be an int and not a string
    req.params.userId = userId;
    req.query.userIdentifier = userIdentifier;
    return next();
  }
  catch (error) {
    // couldn't query database to find userId
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

/**
 * Checks to see that familyId is defined, is a number, and exists in the database
 */
async function validateFamilyId(req, res, next) {
  // userId should be validated already
  const { userId } = req.params;
  const familyId = formatSHA256Hash(req.params.familyId);

  if (areAllDefined(familyId) === false) {
    // familyId was not provided or is invalid format
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('familyId Invalid', global.constant.error.value.INVALID));
  }

  // if familyId is defined and it is a number then continue
  try {
    // queries the database to find familyIds associated with the userId
    const result = await databaseQuery(
      req.connection,
      'SELECT familyId, userId FROM familyMembers WHERE userId = ? AND familyId = ? LIMIT 1',
      [userId, familyId],
    );

    if (result.length === 0) {
      // familyId does not exist in the table
      return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No family found or invalid permissions', global.constant.error.value.INVALID));
    }

    // familyId exists in the table, therefore userId is  part of the family
    // reassign req.params so that the id there is guarrenteed to be an int and not a string
    req.params.familyId = familyId;
    return next();
  }
  catch (error) {
    // couldn't query database to find familyId
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

/**
 * Checks to see that dogId is defined, a number, and exists in the database under familyId provided. If it does then the user owns the dog and invokes next().
 */
async function validateDogId(req, res, next) {
  // familyId should be validated already

  const { familyId } = req.params;
  const dogId = formatNumber(req.params.dogId);

  if (areAllDefined(dogId) === false) {
    // dogId was not provided or is invalid
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('dogId Invalid', global.constant.error.value.INVALID));
  }

  // query database to find out if user has permission for that dogId
  try {
    // finds what dogId (s) the user has linked to their familyId
    // JOIN families as dog must have a family attached to it
    const dog = await databaseQuery(
      req.connection,
      'SELECT dogs.dogId FROM dogs JOIN families ON dogs.familyId = families.familyId WHERE dogs.dogIsDeleted = 0 AND dogs.familyId = ? AND dogs.dogId = ? LIMIT 1',
      [familyId, dogId],
    );

    // search query result to find if the dogIds linked to the familyId match the dogId provided, match means the user owns that dogId

    if (dog.length === 0) {
      // the dogId does not exist and/or the user does not have access to that dogId
      return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('familyId Invalid', global.constant.error.value.INVALID));
    }

    // the dogId exists and it is linked to the familyId, valid!
    // reassign req.params so that the id there is guarrenteed to be an int and not a string
    req.params.dogId = dogId;
    return next();
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

/**
 * Checks to see that logId is defined, a number. and exists in the database under dogId provided. If it does then the dog owns that log and invokes next().
 */
async function validateLogId(req, res, next) {
  // dogId should be validated already

  const { dogId } = req.params;
  const logId = formatNumber(req.params.logId);

  if (areAllDefined(logId) === false) {
    // logId was not provided or is invalid
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('logId Invalid', global.constant.error.value.INVALID));
  }

  // query database to find out if user has permission for that logId
  try {
    // finds what logId (s) the user has linked to their dogId
    // JOIN dogs as log has to have dog still attached to it
    const log = await databaseQuery(
      req.connection,
      'SELECT dogLogs.logId FROM dogLogs JOIN dogs ON dogLogs.dogId = dogs.dogId WHERE dogLogs.logIsDeleted = 0 AND dogLogs.dogId = ? AND dogLogs.logId = ? LIMIT 1',
      [dogId, logId],
    );

    // search query result to find if the logIds linked to the dogIds match the logId provided, match means the user owns that logId

    if (log.length === 0) {
      // the logId does not exist and/or the dog does not have access to that logId
      return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No logs found or invalid permissions', global.constant.error.value.INVALID));
    }

    // the logId exists and it is linked to the dogId, valid!
    // reassign req.params so that the id there is guarrenteed to be an int and not a string
    req.params.logId = logId;
    return next();
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

/**
 * Checks to see that reminderId is defined, a number, and exists in the database under the dogId provided. If it does then the dog owns that reminder and invokes next().
 */
async function validateParamsReminderId(req, res, next) {
  // dogId should be validated already

  const { dogId } = req.params;
  const reminderId = formatNumber(req.params.reminderId);

  if (areAllDefined(reminderId) === false) {
    // reminderId was not provided or is invalid
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('reminderId Invalid', global.constant.error.value.INVALID));
  }

  // query database to find out if user has permission for that reminderId
  try {
    // finds what reminderId (s) the user has linked to their dogId
    // JOIN dogs as reminder must have dog attached to it
    const reminder = await databaseQuery(
      req.connection,
      'SELECT dogReminders.reminderId FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND dogReminders.dogId = ? AND dogReminders.reminderId = ? LIMIT 1',
      [dogId, reminderId],
    );

    // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

    if (reminder.length === 0) {
      // the reminderId does not exist and/or the dog does not have access to that reminderId
      return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No reminders found or invalid permissions', global.constant.error.value.INVALID));
    }

    // the reminderId exists and it is linked to the dogId, valid!
    // reassign req.params so that the id there is guarrenteed to be an int and not a string
    req.params.reminderId = reminderId;
    return next();
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function validateBodyReminderId(req, res, next) {
  // dogId should be validated already

  const { dogId } = req.params;
  // multiple reminders
  const remindersArray = formatArray(req.body.reminders);
  // single reminder
  const singleReminderId = formatNumber(req.body.reminderId);

  if (areAllDefined(remindersArray)) {
    let reminderPromises = [];
    for (let i = 0; i < remindersArray.length; i += 1) {
      const reminderId = formatNumber(remindersArray[i].reminderId);

      if (areAllDefined(reminderId) === false) {
        return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('reminderId Invalid', global.constant.error.value.INVALID));
      }

      // Attempt to locate a reminder. It must match the reminderId provided while being attached to a dog that the user has permission to use
      reminderPromises.push(databaseQuery(
        req.connection,
        'SELECT dogReminders.reminderId FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND dogReminders.dogId = ? AND dogReminders.reminderId = ? LIMIT 1',
        [dogId, reminderId],
      ));
    }

    try {
      reminderPromises = await Promise.all(reminderPromises);
    }
    catch (error) {
      return res.sendResponseForStatusJSONError(400, undefined, error);
    }

    for (let i = 0; i < reminderPromises.length; i += 1) {
      if (reminderPromises[i].length === 0) {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        // eslint-disable-next-line no-await-in-loop
        return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No reminders found or invalid permissions', global.constant.error.value.INVALID));
      }
      // The reminderId exists and it is linked to the dogId! Reassign reminderId to guarantee integer and not a string
      remindersArray[i].reminderId = formatNumber(remindersArray[i].reminderId);
    }
    // successfully checked all reminderIds
    return next();
  }
  // if reminderId is defined and it is a number then continue
  if (areAllDefined(singleReminderId)) {
    // query database to find out if user has permission for that reminderId
    try {
      // finds what reminderId (s) the user has linked to their dogId
      // JOIN dogs as reminder must have dog attached to it
      const reminder = await databaseQuery(
        req.connection,
        'SELECT dogReminders.reminderId FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND dogReminders.dogId = ? AND dogReminders.reminderId = ? LIMIT 1',
        [dogId, singleReminderId],
      );

      // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

      if (reminder.length === 0) {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        return res.sendResponseForStatusJSONError(404, undefined, new ValidationError('No reminders found or invalid permissions', global.constant.error.value.INVALID));
      }

      // the reminderId exists and it is linked to the dogId, valid!
      // reassign req.body so that the id there is guarrenteed to be an int and not a string
      req.body.reminderId = singleReminderId;
      return next();
    }
    catch (error) {
      return res.sendResponseForStatusJSONError(400, undefined, error);
    }
  }
  else {
    // reminders array was not provided or is invalid
    return res.sendResponseForStatusJSONError(400, undefined, new ValidationError('reminders or reminderId Invalid', global.constant.error.value.INVALID));
  }
}

module.exports = {
  validateAppBuild, validateUserId, validateFamilyId, validateDogId, validateLogId, validateParamsReminderId, validateBodyReminderId,
};
