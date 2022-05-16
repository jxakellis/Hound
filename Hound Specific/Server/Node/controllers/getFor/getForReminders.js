const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/validation/validateFormat');

/**
 *  If the query is successful, returns the reminder for the reminderId.
 *  If a problem is encountered, creates and throws custom error
 */
const getReminderQuery = async (req, reminderId) => {
  if (areAllDefined(reminderId) === false) {
    throw new ValidationError('reminderId missing', 'ER_VALUES_MISSING');
  }

  let result;
  try {
    // find reminder that matches the id
    result = await queryPromise(
      req,
      'SELECT * FROM dogReminders WHERE reminderId = ? LIMIT 1',
      [reminderId],
    );
    // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
    // its unnecessary processing and its easier for the reminders to remember their old states
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  return result;
};

/**
 *  If the query is successful, returns an array of all the reminders for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const getRemindersQuery = async (req, dogId) => {
  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }

  try {
    // find reminder that matches the dogId
    const result = await queryPromise(
      req,
      'SELECT * FROM dogReminders WHERE dogId = ? ORDER BY reminderId DESC LIMIT 1000',
      [dogId],
    );
    // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
    // its unnecessary processing and its easier for the reminders to remember their old states

    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getReminderQuery, getRemindersQuery };
