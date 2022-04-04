const { queryPromise } = require('./queryPromise');
const { formatNumber, formatArray } = require('./validateFormat');
const DatabaseError = require('./errors/databaseError');
const ValidationError = require('./errors/validationError');

/**
 * Checks to see that userId is defined, is a number, and exists in the database. TO DO: add authentication to use userId
 */
const validateUserId = async (req, res, next) => {
  // later on use a token here to validate that they have permission to use the userId

  const userId = formatNumber(req.params.userId);

  if (userId) {
    // if userId is defined and it is a number then continue
    try {
      // queries the database to find if the users table contains a user with the provided ID
      const result = await queryPromise(req, 'SELECT userId FROM users WHERE userId = ?', [userId]);

      // checks array of JSON from query to find if userId is contained
      if (result.some((item) => item.userId === userId)) {
        // userId exists in the table
        return next();
      }
      else {
        // userId does not exist in the table
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      // couldn't query database to find userId
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // the only time the userIdentifier would be provided instead of the userId is if the user was retrieving their user information.
    // e.g. they reinstalled the app so are getting their userId to use for future requests.
    // Other wise for any POST, PUT, DELETE User Method or GET, POST, PUT, DELETE log/reminder method (etc...), it has to be the userId
    // and not the userIdentifier.
    // This check only occurs for when it should be userId and not userIdentifier (aka any non-GET /user request)

    // userId was not provided or is invalid format
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('userId Invalid', 'ER_ID_INVALID').toJSON);
  }
};

/**
 * Checks to see that familyId is defined, is a number, and exists in the database
 */
const validateFamilyId = async (req, res, next) => {
  // userId should be validated already

  const userId = formatNumber(req.params.userId);
  const familyId = formatNumber(req.params.familyId);

  if (familyId) {
    // if familyId is defined and it is a number then continue
    try {
      // queries the database to find if the familyMember tables contains a user with the provided ID
      const result = await queryPromise(
        req,
        'SELECT * FROM familyMembers WHERE familyId = ?',
        [familyId],
      );

      // checks array of JSON from query to find if userId is contained
      if (result.some((item) => item.userId === userId)) {
        // userId exists in the table, therefore is part of the family
        return next();
      }
      else {
        // userId does not exist in the table
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No family found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      // couldn't query database to find familyId
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // familyId was not provided or is invalid format
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('familyId Invalid', 'ER_ID_INVALID').toJSON);
  }
};

/**
 * Checks to see that dogId is defined, a number, and exists in the database under userId provided. If it does then the user owns the dog and invokes next().
 */
const validateDogId = async (req, res, next) => {
  // userId should be validated already

  const userId = formatNumber(req.params.userId);
  const dogId = formatNumber(req.params.dogId);

  // if dogId is defined and it is a number then continue
  if (dogId) {
    // query database to find out if user has permission for that dogId
    try {
      // finds what dogId (s) the user has linked to their userId
      const userDogIds = await queryPromise(req, 'SELECT dogs.dogId FROM dogs WHERE dogs.userId = ?', [userId]);

      // search query result to find if the dogIds linked to the userId match the dogId provided, match means the user owns that dogId

      if (userDogIds.some((item) => item.dogId === dogId)) {
        // the dogId exists and it is linked to the userId, valid!
        return next();
      }
      else {
        // the dogId does not exist and/or the user does not have access to that dogId
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No dogs found or invalid permissions', 'ER_ID_INVALID').toJSON);
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // dogId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('dogId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

/**
 * Checks to see that logId is defined, a number. and exists in the database under dogId provided. If it does then the dog owns that log and invokes next().
 */
const validateLogId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = formatNumber(req.params.dogId);
  const logId = formatNumber(req.params.logId);

  // if logId is defined and it is a number then continue
  if (logId) {
    // query database to find out if user has permission for that logId
    try {
      // finds what logId (s) the user has linked to their dogId
      const dogLogIds = await queryPromise(req, 'SELECT logId FROM dogLogs WHERE dogId = ?', [dogId]);

      // search query result to find if the logIds linked to the dogIds match the logId provided, match means the user owns that logId

      if (dogLogIds.some((item) => item.logId === logId)) {
        // the logId exists and it is linked to the dogId, valid!
        return next();
      }
      else {
        // the logId does not exist and/or the dog does not have access to that logId
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No logs found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // logId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('logId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

/**
 * Checks to see that reminderId is defined, a number, and exists in the database under the dogId provided. If it does then the dog owns that reminder and invokes next().
 */
const validateParamsReminderId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = formatNumber(req.params.dogId);
  const reminderId = formatNumber(req.params.reminderId);

  // if reminderId is defined and it is a number then continue
  if (reminderId) {
    // query database to find out if user has permission for that reminderId
    try {
      // finds what reminderId (s) the user has linked to their dogId
      const dogReminderIds = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ?', [dogId]);

      // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

      if (dogReminderIds.some((item) => item.reminderId === reminderId)) {
        // the reminderId exists and it is linked to the dogId, valid!
        return next();
      }
      else {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // reminderId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('reminderId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

const validateBodyReminderId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = formatNumber(req.params.dogId);
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
          const dogReminderIds = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ?', [dogId]);

          // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

          if (dogReminderIds.some((item) => item.reminderId === reminderId)) {
            // the reminderId exists and it is linked to the dogId, valid!
            // Check next reminder
          }
          else {
            // the reminderId does not exist and/or the dog does not have access to that reminderId
            req.rollbackQueries(req);
            return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
          }
        }
        catch (error) {
          req.rollbackQueries(req);
          return res.status(400).json(new DatabaseError(error.code).toJSON);
        }
      }
      else {
        // reminderId was not provided or is invalid
        req.rollbackQueries(req);
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
      const dogReminderIds = await queryPromise(req, 'SELECT reminderId FROM dogReminders WHERE dogId = ?', [dogId]);

      // search query result to find if the reminderIds linked to the dogIds match the reminderId provided, match means the user owns that reminderId

      if (dogReminderIds.some((item) => item.reminderId === singleReminderId)) {
        // the reminderId exists and it is linked to the dogId, valid!
        return next();
      }
      else {
        // the reminderId does not exist and/or the dog does not have access to that reminderId
        req.rollbackQueries(req);
        return res.status(404).json(new ValidationError('No reminders found or invalid permissions', 'ER_NOT_FOUND').toJSON);
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    // reminders array was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('reminders or reminderId Invalid', 'ER_VALUES_INVALID').toJSON);
  }
};

module.exports = {
  validateUserId, validateFamilyId, validateDogId, validateLogId, validateParamsReminderId, validateBodyReminderId,
};
