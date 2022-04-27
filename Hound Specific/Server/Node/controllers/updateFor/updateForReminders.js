const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatDate, formatBoolean, formatArray, areAllDefined,
} = require('../../utils/database/validateFormat');

const { updateCountdownComponents } = require('../reminderComponents/countdown');
const { updateWeeklyComponents } = require('../reminderComponents/weekly');
const { updateMonthlyComponents } = require('../reminderComponents/monthly');
const { updateOneTimeComponents } = require('../reminderComponents/oneTime');
const { updateSnoozeComponents } = require('../reminderComponents/snooze');

/**
 *  Queries the database to create a update reminder. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateReminderQuery = async (req) => {
  const reminderId = req.body.reminderId;
  const { reminderType, reminderAction, reminderCustomActionName } = req.body;
  const reminderExecutionBasis = formatDate(req.body.reminderExecutionBasis);
  const reminderExecutionDate = formatDate(req.body.reminderExecutionDate);
  const reminderIsEnabled = formatBoolean(req.body.reminderIsEnabled);

  if (areAllDefined([reminderId, reminderType, reminderAction, reminderExecutionBasis, reminderIsEnabled]) === false) {
    throw new ValidationError('reminderId, reminderType, reminderAction, reminderExecutionBasis, or reminderIsEnabled missing', 'ER_VALUES_MISSING');
  }

  try {
    // update reminder components
    if (reminderType === 'countdown') {
      await updateCountdownComponents(req, req.body);
    }
    else if (reminderType === 'weekly') {
      await updateWeeklyComponents(req, req.body);
    }
    else if (reminderType === 'monthly') {
      await updateMonthlyComponents(req, req.body);
    }
    else if (reminderType === 'oneTime') {
      await updateOneTimeComponents(req, req.body);
    }
    else {
      throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
    }

    // no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if snoozeIsEnabled is changing to false
    await updateSnoozeComponents(req, req.body);

    // update primary bit of reminder
    await queryPromise(
      req,
      'UPDATE dogReminders SET reminderType = ?, reminderAction = ?, reminderCustomActionName = ?, reminderExecutionBasis = ?, reminderExecutionDate = ?, reminderIsEnabled = ?  WHERE reminderId = ?',
      [reminderType, reminderAction, reminderCustomActionName, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled, reminderId],
    );

    return [req.body];
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  Queries the database to update multiple reminders. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateRemindersQuery = async (req) => {
  // assume .reminders is an array
  const reminders = formatArray(req.body.reminders);

  // synchronously iterate through all reminders provided to update them all
  // if there is a problem, we rollback all our queries and send the failure response
  // if there are no problems with any of the reminders, we commit our queries and send the success response
  for (let i = 0; i < reminders.length; i += 1) {
    const reminderId = reminders[i].reminderId;
    const { reminderAction, reminderCustomActionName, reminderType } = reminders[i];
    const reminderExecutionBasis = formatDate(reminders[i].reminderExecutionBasis);
    const reminderExecutionDate = formatDate(reminders[i].reminderExecutionDate);
    const reminderIsEnabled = formatBoolean(reminders[i].reminderIsEnabled);

    if (areAllDefined([reminderId, reminderType, reminderAction, reminderExecutionBasis, reminderIsEnabled]) === false) {
      throw new ValidationError('reminderid, reminderAction, reminderType, reminderExecutionBasis, or reminderIsEnabled missing', 'ER_VALUES_MISSING');
    }

    try {
      // update reminder components
      if (reminderType === 'countdown') {
        await updateCountdownComponents(req, reminders[i]);
      }
      else if (reminderType === 'weekly') {
        await updateWeeklyComponents(req, reminders[i]);
      }
      else if (reminderType === 'monthly') {
        await updateMonthlyComponents(req, reminders[i]);
      }
      else if (reminderType === 'oneTime') {
        await updateOneTimeComponents(req, reminders[i]);
      }
      else {
        throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
      }

      // no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if snoozeIsEnabled is changing to false
      await updateSnoozeComponents(req, reminders[i]);

      // update primary bit of reminder
      await queryPromise(
        req,
        'UPDATE dogReminders SET reminderType = ?, reminderAction = ?, reminderCustomActionName = ?, reminderExecutionBasis = ?, reminderExecutionDate = ?, reminderIsEnabled = ?  WHERE reminderId = ?',
        [reminderType, reminderAction, reminderCustomActionName, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled, reminderId],
      );
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
  // return must be outside for loop, otherwise function won't return
  // eslint-disable-next-line no-useless-return
  return req.body.reminders;
};

module.exports = { updateReminderQuery, updateRemindersQuery };
