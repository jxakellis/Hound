const { queryPromise } = require('../database/queryPromise');
const { formatNumber, formatArray, areAllDefined } = require('./validateFormat');
const DatabaseError = require('../errors/databaseError');
const ValidationError = require('../errors/validationError');

/**
 * Checks to see that userId and userIdentifier are defined, are valid, and exist in the database.
 */
const validateUserId = async (req, res, next) => {
  // later on use a token here to validate that they have permission to use the userId

  const userId = formatNumber(req.params.userId);
  const userIdentifier = req.query.userIdentifier;

  if (userId && areAllDefined(userIdentifier)) {
    // if userId is defined and it is a number then continue
    try {
      // queries the database to find if the users table contains a user with the provided ID
      const result = await queryPromise(
        req,
        'SELECT userId, userIdentifier FROM users WHERE userId = ? AND userIdentifier = ? LIMIT 1',
        [userId, userIdentifier],
      );

      if (result.length === 1) {
        // userId exists in the table for given userId and identifier, so all valid
        // reassign req.params so that the id there is guarrenteed to be an int and not a string
        req.params.userId = userId;
        return next();
      }
      else {
        // userId does not exist in the table
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      // couldn't query database to find userId
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // userId was not provided or is invalid format OR userIdentifier was not provided or is invalid format
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userId or userIdentifier Invalid', 'ER_ID_INVALID').toJSON);
  }
};

/**
 * Checks to see that familyId is defined, is a number, and exists in the database
 */
const validateFamilyId = async (req, res, next) => {
  // userId should be validated already
  const userId = req.params.userId;
  const familyId = formatNumber(req.params.familyId);

  if (familyId) {
    // if familyId is defined and it is a number then continue
    try {
      // queries the database to find familyIds associated with the userId
      const result = await queryPromise(
        req,
        'SELECT familyId, userId FROM familyMembers WHERE userId = ? AND familyId = ? LIMIT 1',
        [userId, familyId],
      );

      if (result.length === 1) {
        // familyId exists in the table, therefore userId is  part of the family
        // reassign req.params so that the id there is guarrenteed to be an int and not a string
        req.params.familyId = familyId;
        return next();
      }
      else {
        // familyId does not exist in the table
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No family found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      // couldn't query database to find familyId
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // familyId was not provided or is invalid format
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('familyId Invalid', 'ER_ID_INVALID').toJSON);
  }
};

/**
 * Checks to see that dogId is defined, a number, and exists in the database under familyId provided. If it does then the user owns the dog and invokes next().
 */
const validateDogId = async (req, res, next) => {
  // familyId should be validated already

  const familyId = req.params.familyId;
  const dogId = formatNumber(req.params.dogId);

  // if dogId is defined and it is a number then continue
  if (dogId) {
    // query database to find out if user has permission for that dogId
    try {
      // finds what dogId (s) the user has linked to their familyId
      const dog = await queryPromise(req, 'SELECT dogId FROM dogs WHERE familyId = ? AND dogId = ? LIMIT 1', [familyId, dogId]);

      // search query result to find if the dogIds linked to the familyId match the dogId provided, match means the user owns that dogId

      if (dog.length === 1) {
        // the dogId exists and it is linked to the familyId, valid!
        // reassign req.params so that the id there is guarrenteed to be an int and not a string
        req.params.dogId = dogId;
        return next();
      }
      else {
        // the dogId does not exist and/or the user does not have access to that dogId
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No dogs found or invalid permissions', 'ER_ID_INVALID').toJSON);
      }
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // dogId was not provided or is invalid
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('dogId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

/**
 * Checks to see that logId is defined, a number. and exists in the database under dogId provided. If it does then the dog owns that log and invokes next().
 */
const validateLogId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = req.params.dogId;
  const logId = formatNumber(req.params.logId);

  // if logId is defined and it is a number then continue
  if (logId) {
    // query database to find out if user has permission for that logId
    try {
      // finds what logId (s) the user has linked to their dogId
      const log = await queryPromise(req, 'SELECT logId FROM dogLogs WHERE dogId = ? AND logId = ? LIMIT 1', [dogId, logId]);

      // search query result to find if the logIds linked to the dogIds match the logId provided, match means the user owns that logId

      if (log.length === 1) {
        // the logId exists and it is linked to the dogId, valid!
        // reassign req.params so that the id there is guarrenteed to be an int and not a string
        req.params.logId = logId;
        return next();
      }
      else {
        // the logId does not exist and/or the dog does not have access to that logId
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No logs found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // logId was not provided or is invalid
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('logId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

/**
 * Checks to see that reminderId is defined, a number, and exists in the database under the dogId provided. If it does then the dog owns that reminder and invokes next().
 */
const validateParamsReminderId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = req.params.dogId;
  const reminderId = formatNumber(req.params.reminderId);

  // if reminderId is defined and it is a number then continue
  if (reminderId) {
    // query database to find out if user has permission for that reminderId
    try {
      // finds what reminderId (s) the user has linked to their dogId
      const reminder = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ? AND reminderId = ? LIMIT 1', [dogId, reminderId]);

      // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

      if (reminder.length === 1) {
        // the reminderId exists and it is linked to the dogId, valid!
        // reassign req.params so that the id there is guarrenteed to be an int and not a string
        req.params.reminderId = reminderId;
        return next();
      }
      else {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // reminderId was not provided or is invalid
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('reminderId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

const validateBodyReminderId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = req.params.dogId;
  // multiple reminders
  const reminders = formatArray(req.body.reminders);
  // single reminder
  const singleReminderId = formatNumber(req.body.reminderId);

  // if reminders array is defined and array then continue
  if (reminders) {
    for (let i = 0; i < reminders.length; i += 1) {
      const reminderId = formatNumber(reminders[i].reminderId);

      // if reminderId is defined and it is a number then continue
      if (reminderId) {
        // query database to find out if user has permission for that reminderId
        try {
          // finds what reminderId (s) the user has linked to their dogId
          const reminder = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ? AND reminderId = ? LIMIT 1', [dogId, reminderId]);

          // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

          if (reminder.length === 1) {
            // the reminderId exists and it is linked to the dogId, valid!
            // reassign reminder body so that the id there is guarrenteed to be an int and not a string
            reminders[i].reminderId = reminderId;
            // Check next reminder
          }
          else {
            // the reminderId does not exist and/or the dog does not have access to that reminderId
            await req.rollbackQueries(req);
            return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
          }
        }
        catch (error) {
          await req.rollbackQueries(req);
          return res.status(400).json(new DatabaseError(error.code).toJSON);
        }
      }
      else {
        // reminderId was not provided or is invalid
        await req.rollbackQueries(req);
        return res.status(400).json(new ValidationError('reminderId Invalid', 'ER_VALUES_INVALID').toJSON);
      }
    }
    // successfully checked all reminderIds
    return next();
  }
  // if reminderId is defined and it is a number then continue
  else if (singleReminderId) {
    // query database to find out if user has permission for that reminderId
    try {
      // finds what reminderId (s) the user has linked to their dogId
      const reminder = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ? AND reminderId = ?', [dogId, singleReminderId]);

      // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

      if (reminder.length === 1) {
        // the reminderId exists and it is linked to the dogId, valid!
        // reassign req.body so that the id there is guarrenteed to be an int and not a string
        req.body.reminderId = singleReminderId;
        return next();
      }
      else {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        await req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      await req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // reminders array was not provided or is invalid
    await req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('reminders or reminderId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

module.exports = {
  validateUserId, validateFamilyId, validateDogId, validateLogId, validateParamsReminderId, validateBodyReminderId,
};