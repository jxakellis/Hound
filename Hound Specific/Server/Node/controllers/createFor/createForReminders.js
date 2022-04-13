const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatDate, formatBoolean, formatNumber, formatArray, areAllDefined,
} = require('../../utils/database/validateFormat');

const { createCountdownComponents } = require('../reminderComponents/countdown');
const { createWeeklyComponents } = require('../reminderComponents/weekly');
const { createMonthlyComponents } = require('../reminderComponents/monthly');
const { createOneTimeComponents } = require('../reminderComponents/oneTime');

/**
 *  Queries the database to create a single reminder. If the query is successful, then returns the reminder with created reminderId.
 *  If a problem is encountered, creates and throws custom error
 */
const createReminderQuery = async (req) => {
  const dogId = formatNumber(req.params.dogId);
  const { reminderAction, reminderCustomActionName, reminderType } = req.body;
  const reminderExecutionBasis = formatDate(req.body.reminderExecutionBasis);
  const reminderExecutionDate = formatDate(req.body.reminderExecutionDate);
  const reminderIsEnabled = formatBoolean(req.body.reminderIsEnabled);

  // check to see that necessary generic reminder componetns are present
  if (areAllDefined([reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled]) === false) {
    // >= 1 of the objects are undefined
    throw new ValidationError('reminderAction, reminderType, reminderExecutionBasis, or reminderIsEnabled missing', 'ER_VALUES_MISSING');
  }

  // define out here so reminderId can be accessed in catch block to delete entries
  let reminderId;

  try {
    // first insert to main reminder table to get reminderId, then insert to other tables
    const result = await queryPromise(
      req,
      'INSERT INTO dogReminders(dogId, reminderAction, reminderCustomActionName, reminderType, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [dogId, reminderAction, reminderCustomActionName, reminderType, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled],
    );
    reminderId = formatNumber(result.insertId);
    req.body.reminderId = reminderId;

    // no need to check for snooze components as a newly created reminder cant be snoozed, it can only be updated to be snoozing
    if (reminderType === 'countdown') {
      await createCountdownComponents(req, req.body);
    }
    else if (reminderType === 'weekly') {
      await createWeeklyComponents(req, req.body);
    }
    else if (reminderType === 'monthly') {
      await createMonthlyComponents(req, req.body);
    }
    else if (reminderType === 'oneTime') {
      await createOneTimeComponents(req, req.body);
    }
    else {
      // nothing matched reminderType
      throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
    }
    // was able to successfully create components for a certain timing style
    return [req.body];
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
   * Queries the database to create a multiple reminders. If the query is successful, then returns the reminders with their created reminderIds.
 *  If a problem is encountered, creates and throws custom error
   */
const createRemindersQuery = async (req) => {
  // assume .reminders is an array
  const dogId = formatNumber(req.params.dogId);
  const reminders = formatArray(req.body.reminders);
  const createdReminders = [];

  // synchronously iterate through all reminders provided to create them all
  // if there is a problem, we rollback all our queries and send the failure response
  // if there is no problem, we append the created reminder (with its freshly assigned id) to the array
  // if there are no problems with any of the reminders, we commit our queries and send the success response
  for (let i = 0; i < reminders.length; i += 1) {
    const { reminderAction, reminderCustomActionName, reminderType } = reminders[i];
    const reminderExecutionBasis = formatDate(reminders[i].reminderExecutionBasis);
    const reminderExecutionDate = formatDate(reminders[i].reminderExecutionDate);
    const reminderIsEnabled = formatBoolean(reminders[i].reminderIsEnabled);

    // check to see that necessary generic reminder componetns are present
    if (areAllDefined([reminderAction, reminderType, reminderExecutionBasis, reminderIsEnabled]) === false) {
      // >= 1 of the objects are undefined
      // req.rollbackQueries(req);
      // return res.status(400).json(new ValidationError('reminderAction, reminderType, reminderExecutionBasis, or reminderIsEnabled missing', 'ER_VALUES_MISSING'));
      throw new ValidationError('reminderAction, reminderType, reminderExecutionBasis, or reminderIsEnabled missing', 'ER_VALUES_MISSING');
    }
    // define out here so reminderId can be accessed in catch block to delete entries
    let reminderId;

    try {
      // first insert to main reminder table to get reminderId, then insert to other tables
      const result = await queryPromise(
        req,
        'INSERT INTO dogReminders(dogId, reminderAction, reminderCustomActionName, reminderType, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [dogId, reminderAction, reminderCustomActionName, reminderType, reminderExecutionBasis, reminderExecutionDate, reminderIsEnabled],
      );
      reminderId = formatNumber(result.insertId);
      reminders[i].reminderId = reminderId;
      // no need to check for snooze components as a newly created reminder cant be snoozed, it can only be updated to be snoozing
      if (reminderType === 'countdown') {
        await createCountdownComponents(req, reminders[i]);
      }
      else if (reminderType === 'weekly') {
        await createWeeklyComponents(req, reminders[i]);
      }
      else if (reminderType === 'monthly') {
        await createMonthlyComponents(req, reminders[i]);
      }
      else if (reminderType === 'oneTime') {
        await createOneTimeComponents(req, reminders[i]);
      }
      else {
        // nothing matched reminderType
        throw new ValidationError('reminderType Invalid', 'ER_VALUES_INVALID');
      }
      // was able to successfully create components for a certain timing style
      createdReminders.push(reminders[i]);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
  // everything was successful so we return the created reminders
  return createdReminders;
};

module.exports = { createReminderQuery, createRemindersQuery };
