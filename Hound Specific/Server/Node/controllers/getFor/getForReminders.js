const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { formatDate, areAllDefined } = require('../../main/tools/format/formatObject');

/**
 *  If the query is successful, returns the reminder for the reminderId.
 *  If a problem is encountered, creates and throws custom error
 */
const getReminderQuery = async (req, reminderId) => {
  const lastServerSynchronization = formatDate(req.query.lastServerSynchronization);

  if (areAllDefined(reminderId) === false) {
    throw new ValidationError('reminderId missing', 'ER_VALUES_MISSING');
  }

  try {
    let result;

    if (areAllDefined(lastServerSynchronization)) {
      // find reminder that matches the id
      result = await queryPromise(
        req,
        'SELECT * FROM dogReminders WHERE reminderLastModified >= ? AND reminderId = ? LIMIT 1',
        [lastServerSynchronization, reminderId],
      );
    }
    else {
      // find reminder that matches the id
      result = await queryPromise(
        req,
        'SELECT * FROM dogReminders WHERE reminderId = ? LIMIT 1',
        [reminderId],
      );
    }

    // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
    // its unnecessary processing and its easier for the reminders to remember their old states
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  If the query is successful, returns an array of all the reminders for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const getRemindersQuery = async (req, dogId) => {
  const lastServerSynchronization = formatDate(req.query.lastServerSynchronization);

  if (areAllDefined(dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }

  try {
    let result;

    if (areAllDefined(lastServerSynchronization)) {
      result = await queryPromise(
        req,
        'SELECT * FROM dogReminders WHERE reminderLastModified >= ? AND dogId = ? LIMIT 18446744073709551615',
        [lastServerSynchronization, dogId],
      );
    }
    else {
      // find reminder that matches the dogId
      result = await queryPromise(
        req,
        'SELECT * FROM dogReminders WHERE dogId = ? LIMIT 18446744073709551615',
        [dogId],
      );
    }

    // don't trim 'unnecessary' components (e.g. if weekly only send back weekly components)
    // its unnecessary processing and its easier for the reminders to remember their old states

    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getReminderQuery, getRemindersQuery };
