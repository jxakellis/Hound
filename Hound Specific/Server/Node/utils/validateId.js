const { queryPromise } = require('./queryPromise');
const { formatNumber, formatArray } = require('./validateFormat');

/**
 * Checks to see that userId is defined, is a number, and exists in the database. TO DO: add authentication to use userId
 * @param {*} req
 * @param {*} res
 * @param {*} next
 * @returns
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
        return res.status(404).json({ message: 'Invalid Parameters; No user found or invalid permissions', error: 'ER_NO_USER_FOUND' });
      }
    }
    catch (error) {
      // couldn't query database to find userId
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  else {
    // userId was not provided or is invalid format
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters; userId Invalid' });
  }
};

/**
 * Checks to see that dogId is defined, a number, and exists in the database under userId provided. If it does then the user owns the dog and invokes next().
 * @param {*} req
 * @param {*} res
 * @param {*} next
 * @returns
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
        return res.status(404).json({ message: 'Couldn\'t Find Resource; No dogs found or invalid permissions' });
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  else {
    // dogId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters; dogId Invalid' });
  }
};

/**
 * Checks to see that logId is defined, a number. and exists in the database under dogId provided. If it does then the dog owns that log and invokes next().
 * @param {*} req
 * @param {*} res
 * @param {*} next
 * @returns
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
        return res.status(404).json({ message: 'Couldn\'t Find Resource; No logs found or invalid permissions' });
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  else {
    // logId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters; logId Invalid' });
  }
};

/**
 * Checks to see that reminderId is defined, a number, and exists in the database under the dogId provided. If it does then the dog owns that reminder and invokes next().
 * @param {*} req
 * @param {*} res
 * @param {*} next
 * @returns
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
        return res.status(404).json({ message: 'Couldn\'t Find Resource; No reminders found or invalid permissions' });
      }
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  else {
    // reminderId was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters; reminderId Invalid' });
  }
};

const validateBodyReminderId = async (req, res, next) => {
  // dogId should be validated already

  const dogId = formatNumber(req.params.dogId);
  const reminders = formatArray(req.body.reminders);

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
            return res.status(404).json({ message: 'Couldn\'t Find Resource; No reminders found or invalid permissions' });
          }
        }
        catch (error) {
          req.rollbackQueries(req);
          return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
        }
      }
      else {
        // reminderId was not provided or is invalid
        req.rollbackQueries(req);
        return res.status(400).json({ message: 'Invalid Parameters; reminderId Invalid' });
      }
    }
    // successfully checked all reminderIds
    return next();
  }
  else {
    // reminders array was not provided or is invalid
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Parameters; reminders Invalid' });
  }
};

module.exports = {
  validateUserId, validateDogId, validateLogId, validateParamsReminderId, validateBodyReminderId,
};
