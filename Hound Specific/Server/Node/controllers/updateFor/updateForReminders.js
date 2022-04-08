const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/queryPromise');
const {
  formatDate, formatBoolean, formatNumber, formatArray, atLeastOneDefined, areAllDefined,
} = require('../../utils/validateFormat');

const { updateCountdownComponents } = require('../reminderComponents/countdown');
const { updateWeeklyComponents } = require('../reminderComponents/weekly');
const { updateMonthlyComponents } = require('../reminderComponents/monthly');
const { updateOneTimeComponents } = require('../reminderComponents/oneTime');
const { updateSnoozeComponents } = require('../reminderComponents/snooze');
const delLeftOverReminderComponents = require('../../utils/delete').deleteLeftoverReminderComponents;

/**
 *  Queries the database to create a update reminder. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
const updateReminderQuery = async (req) => {
  const reminderId = formatNumber(req.body.reminderId);
  const { reminderAction, reminderCustomActionName, reminderType } = req.body;
  const reminderExecutionBasis = formatDate(req.body.reminderExecutionBasis);
  const reminderExecutionDate = formatDate(req.body.reminderExecutionDate);
  const reminderIsEnabled = formatBoolean(req.body.reminderIsEnabled);
  const snoozeIsEnabled = formatBoolean(req.body.snoozeIsEnabled);

  if (areAllDefined(reminderId) === false) {
    throw new ValidationError('reminderId missing', 'ER_ID_MISSING');
  }
  if (atLeastOneDefined([reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled, snoozeIsEnabled]) === false) {
    throw new ValidationError('No reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled, or snoozeIsEnabled provided', 'ER_NO_VALUES_PROVIDED');
  }

  try {
    if (reminderAction) {
      if (reminderAction === 'Custom') {
        await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ?, reminderCustomActionName = ?  WHERE reminderId = ?', [reminderAction, reminderCustomActionName, reminderId]);
      }
      else {
        await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ? WHERE reminderId = ?', [reminderAction, reminderId]);
      }
    }

    if (reminderExecutionBasis) {
      await queryPromise(req, 'UPDATE dogReminders SET reminderExecutionBasis = ? WHERE reminderId = ?', [reminderExecutionBasis, reminderId]);
    }
    if (reminderExecutionDate) {
      await queryPromise(req, 'UPDATE dogReminders SET reminderExecutionDate = ? WHERE reminderId = ?', [reminderExecutionDate, reminderId]);
    }
    if (areAllDefined(reminderIsEnabled)) {
      await queryPromise(req, 'UPDATE dogReminders SET reminderIsEnabled = ? WHERE reminderId = ?', [reminderIsEnabled, reminderId]);
    }
    if (reminderType) {
      if (reminderType === 'countdown') {
        // add new
        await updateCountdownComponents(req, req.body);
      }
      else if (reminderType === 'weekly') {
        // add new
        await updateWeeklyComponents(req, req.body);
      }
      else if (reminderType === 'monthly') {
        // add new
        await updateMonthlyComponents(req, req.body);
      }
      else if (reminderType === 'oneTime') {
        // add new
        await updateOneTimeComponents(req, req.body);
      }
      else {
        throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
      }

      // switch reminder to new mode
      await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
      // delete old components since reminder is successfully switched to new mode
      await delLeftOverReminderComponents(req, reminderId, reminderType);
    }
    // do last since reminderType will delete snooze components
    if (areAllDefined(snoozeIsEnabled)) {
      await updateSnoozeComponents(req, req.body);
      // no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if snoozeIsEnabled is changing to false
    }
    return;
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
    const reminderId = formatNumber(reminders[i].reminderId);
    const { reminderAction, reminderCustomActionName, reminderType } = reminders[i];
    const reminderExecutionBasis = formatDate(reminders[i].reminderExecutionBasis);
    const reminderExecutionDate = formatDate(reminders[i].reminderExecutionDate);
    const reminderIsEnabled = formatBoolean(reminders[i].reminderIsEnabled);
    const snoozeIsEnabled = formatBoolean(reminders[i].snoozeIsEnabled);

    if (areAllDefined(reminderId) === false) {
      throw new ValidationError('reminderId missing', 'ER_ID_MISSING');
    }
    if (atLeastOneDefined([reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled, snoozeIsEnabled]) === false) {
      throw new ValidationError('No reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled, or snoozeIsEnabled provided', 'ER_NO_VALUES_PROVIDED');
    }

    try {
      if (reminderAction) {
        if (reminderAction === 'Custom') {
          await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ?, reminderCustomActionName = ? WHERE reminderId = ?', [reminderAction, reminderCustomActionName, reminderId]);
        }
        else {
          await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ? WHERE reminderId = ?', [reminderAction, reminderId]);
        }
      }

      if (reminderExecutionBasis) {
        await queryPromise(req, 'UPDATE dogReminders SET reminderExecutionBasis = ? WHERE reminderId = ?', [reminderExecutionBasis, reminderId]);
      }
      if (reminderExecutionDate) {
        await queryPromise(req, 'UPDATE dogReminders SET reminderExecutionDate = ? WHERE reminderId = ?', [reminderExecutionDate, reminderId]);
      }
      if (areAllDefined(reminderIsEnabled)) {
        await queryPromise(req, 'UPDATE dogReminders SET reminderIsEnabled = ? WHERE reminderId = ?', [reminderIsEnabled, reminderId]);
      }
      if (reminderType) {
        if (reminderType === 'countdown') {
          // add new
          await updateCountdownComponents(req, reminders[i]);
        }
        else if (reminderType === 'weekly') {
          // add new
          await updateWeeklyComponents(req, reminders[i]);
        }
        else if (reminderType === 'monthly') {
          // add new
          await updateMonthlyComponents(req, reminders[i]);
        }
        else if (reminderType === 'oneTime') {
          // add new
          await updateOneTimeComponents(req, reminders[i]);
        }
        else {
          throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
        }

        // switch reminder to new mode
        await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
        // delete old components since reminder is successfully switched to new mode
        await delLeftOverReminderComponents(req, reminderId, reminderType);
      }
      // do last since reminderType will delete snooze components
      if (areAllDefined(snoozeIsEnabled)) {
        await updateSnoozeComponents(req, reminders[i]);
        // no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if snoozeIsEnabled is changing to false
      }
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
  // return must be outside for loop, otherwise function won't return
  // eslint-disable-next-line no-useless-return
  return;
};

module.exports = { updateReminderQuery, updateRemindersQuery };
