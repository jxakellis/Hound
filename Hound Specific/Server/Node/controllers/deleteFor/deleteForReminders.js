const {
  formatNumber, formatArray,
} = require('../../utils/validateFormat');
const { deleteReminder } = require('../../utils/delete');

/**
 *  Queries the database to delete a single reminder. If the query is successful, then sends response of result.
 *  If an error is encountered, sends a response of the message and error
 */
const deleteReminderQuery = async (req, res) => {
  const reminderId = formatNumber(req.params.reminderId);

  try {
    await deleteReminder(req, reminderId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.code });
  }
};

/**
 *  Queries the database to delete multiple reminders. If the query is successful, then sends response of result.
 *  If an error is encountered, sends a response of the message and error
 */
const deleteRemindersQuery = async (req, res) => {
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
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.code });
    }
  }
  req.commitQueries(req);
  return res.status(200).json({ result: '' });
};

module.exports = { deleteReminderQuery, deleteRemindersQuery };
