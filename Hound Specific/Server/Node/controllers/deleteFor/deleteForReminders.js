const DatabaseError = require('../../utils/errors/databaseError');
const {
  formatNumber, formatArray,
} = require('../../utils/validateFormat');
const { deleteReminder } = require('../../utils/delete');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteReminderQuery = async (req) => {
  const reminderId = formatNumber(req.body.reminderId);

  try {
    await deleteReminder(req, reminderId);
    // req.commitQueries(req);
    // return res.status(200).json({ result: '' });
    return;
  }
  catch (error) {
    // req.rollbackQueries(req);
    // return res.status(400).json(new DatabaseError(error.code).toJSON);
    throw new DatabaseError(error.code);
  }
};

/**
 *  Queries the database to delete multiple reminders. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteRemindersQuery = async (req) => {
  // assume .reminders is an array
  const reminders = formatArray(req.body.reminders);

  // iterate through all reminders provided to update them all
  // if there is a problem, then we return that problem (function that invokes this will roll back requests)
  // if there are no problems with any of the reminders, we return ''.
  for (let i = 0; i < reminders.length; i += 1) {
    const reminderId = formatNumber(reminders[i].reminderId);

    try {
      await deleteReminder(req, reminderId);
    }
    catch (error) {
      // req.rollbackQueries(req);
      // return res.status(400).json(new DatabaseError(error.code).toJSON);
      throw new DatabaseError(error.code);
    }
  }
  // req.commitQueries(req);
  // return res.status(200).json({ result: '' });
  return '';
};

module.exports = { deleteReminderQuery, deleteRemindersQuery };
