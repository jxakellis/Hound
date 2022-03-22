const { queryPromise } = require('../utils/queryPromise');
const {
  formatDate, formatBoolean, formatNumber, areAllDefined, atLeastOneDefined,
} = require('../utils/validateFormat');

const { queryReminder, queryReminders } = require('./queryFor/queryForReminders');
const { createCountdownComponents, updateCountdownComponents } = require('./reminderComponents/countdown');
const { createWeeklyComponents, updateWeeklyComponents } = require('./reminderComponents/weekly');
const { createMonthlyComponents, updateMonthlyComponents } = require('./reminderComponents/monthly');
const { createOneTimeComponents, updateOneTimeComponents } = require('./reminderComponents/oneTime');
const { updateSnoozeComponents } = require('./reminderComponents/snooze');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
*/

const getReminders = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);
  const reminderId = formatNumber(req.params.reminderId);

  // reminderId was provided
  if (reminderId) {
    try {
      // left joins dogReminders and component tables so that a reminder has all of its components attached
      // tables where the dogReminder isn't present (i.e. its reminderType is different) will just append lots of null values to result
      const result = await queryReminder(req, reminderId);

      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  // no reminderId
  else {
    try {
      // get the reminders
      const result = await queryReminders(req, dogId);

      if (result.length === 0) {
        // successful but empty array, no reminders to return
        req.commitQueries(req);
        return res.status(204).json({ result: [] });
      }

      // array has items, meaning there were reminders found, successful!
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      // error when trying to do query to database
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
};

const createReminder = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);
  const { reminderAction } = req.body;
  const { customTypeName } = req.body;
  const { reminderType } = req.body;
  const executionBasis = formatDate(req.body.executionBasis);
  const isEnabled = formatBoolean(req.body.isEnabled);

  // check to see that necessary generic reminder componetns are present
  if (areAllDefined([reminderAction, reminderType, executionBasis, isEnabled]) === false) {
    // >= 1 of the objects are undefined
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; reminderAction, reminderType, executionBasis, or isEnabled missing ' });
  }
  // if the reminder is custom, then it needs its custom name
  if (reminderAction === 'Custom' && !customTypeName) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No customTypeName provided for "Custom" reminderAction' });
  }

  // define out here so reminderId can be accessed in catch block to delete entries
  let reminderId;

  try {
    // need to check reminderType before querying because a partially correct timing style can have the query data added to the database but kick back a warning, we only want exact matches

    // no need to check for snooze components as a newly created reminder cant be snoozed, it can only be updated to be snoozing
    if (reminderType === 'countdown') {
      // first insert to main reminder table to get reminderId, then insert to other tables
      const result = await queryPromise(
        req,
        'INSERT INTO dogReminders(dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
        [dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled],
      );
      reminderId = formatNumber(result.insertId);
      await createCountdownComponents(req, reminderId);
    }
    else if (reminderType === 'weekly') {
      // first insert to main reminder table to get reminderId, then insert to other tables
      const result = await queryPromise(
        req,
        'INSERT INTO dogReminders(dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
        [dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled],
      );
      reminderId = formatNumber(result.insertId);
      await createWeeklyComponents(req, reminderId);
    }
    else if (reminderType === 'monthly') {
      // first insert to main reminder table to get reminderId, then insert to other tables
      const result = await queryPromise(
        req,
        'INSERT INTO dogReminders(dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
        [dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled],
      );
      reminderId = formatNumber(result.insertId);
      await createMonthlyComponents(req, reminderId);
    }
    else if (reminderType === 'oneTime') {
      // first insert to main reminder table to get reminderId, then insert to other tables
      const result = await queryPromise(
        req,
        'INSERT INTO dogReminders(dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
        [dogId, reminderAction, customTypeName, reminderType, executionBasis, isEnabled],
      );
      reminderId = formatNumber(result.insertId);
      await createOneTimeComponents(req, reminderId);
    }
    else {
      // nothing matched reminderType
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Body; reminderType Invalid' });
    }
    // was able to successfully create components for a certain timing style
    req.commitQueries(req);
    return res.status(200).json({ result: reminderId });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.code });
  }
};

const delLeftOverReminderComponents = require('../utils/delete').deleteLeftoverReminderComponents;

const updateReminder = async (req, res) => {
  // FIX ME, if updating to a new reminderType, need to create data instead of just updating. current implementation doesn't add data to a the new table for reminderType so update queries go nowhere

  const reminderId = formatNumber(req.params.reminderId);
  const { reminderAction } = req.body;
  const { customTypeName } = req.body;
  const { reminderType } = req.body;
  const executionBasis = formatDate(req.body.executionBasis);
  const isEnabled = formatBoolean(req.body.isEnabled);
  const isSnoozed = formatBoolean(req.body.isSnoozed);

  if (atLeastOneDefined([reminderAction, reminderType, executionBasis, isEnabled, isSnoozed]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No reminderId, reminderAction, reminderType, executionBasis, isEnabled, or isSnoozed provided' });
  }
  if (reminderAction === 'Custom' && !customTypeName) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No customTypeName provided for "Custom" reminderAction' });
  }

  try {
    if (reminderAction) {
      if (reminderAction === 'Custom') {
        await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ?, customTypeName = ?  WHERE reminderId = ?', [reminderAction, customTypeName, reminderId]);
      }
      else {
        await queryPromise(req, 'UPDATE dogReminders SET reminderAction = ? WHERE reminderId = ?', [reminderAction, reminderId]);
      }
    }

    if (executionBasis) {
      await queryPromise(req, 'UPDATE dogReminders SET executionBasis = ? WHERE reminderId = ?', [executionBasis, reminderId]);
    }
    if (typeof isEnabled !== 'undefined') {
      await queryPromise(req, 'UPDATE dogReminders SET isEnabled = ? WHERE reminderId = ?', [isEnabled, reminderId]);
    }
    // save me for second to last since I have a high chance of failing
    if (reminderType) {
      if (reminderType === 'countdown') {
        // add new
        await updateCountdownComponents(req, reminderId);
        // switch reminder to new mode
        await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
        // delete old components since reminder is successfully switched to new mode
        await delLeftOverReminderComponents(req, reminderId, reminderType);
      }
      else if (reminderType === 'weekly') {
        // add new
        await updateWeeklyComponents(req, reminderId);
        // switch reminder to new mode
        await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
        // delete old components since reminder is successfully switched to new mode
        await delLeftOverReminderComponents(req, reminderId, reminderType);
      }
      else if (reminderType === 'monthly') {
        // add new
        await updateMonthlyComponents(req, reminderId);
        // switch reminder to new mode
        await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
        // delete old components since reminder is successfully switched to new mode
        await delLeftOverReminderComponents(req, reminderId, reminderType);
      }
      else if (reminderType === 'oneTime') {
        // add new
        await updateOneTimeComponents(req, reminderId);
        // switch reminder to new mode
        await queryPromise(req, 'UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId]);
        // delete old components since reminder is successfully switched to new mode
        await delLeftOverReminderComponents(req, reminderId, reminderType);
      }
      else {
        req.rollbackQueries(req);
        return res.status(400).json({ message: 'Invalid Body; reminderType Invalid' });
      }
    }
    // do last since reminderType will delete snooze components
    if (typeof isSnoozed !== 'undefined') {
      await updateSnoozeComponents(reminderId, req);
      // no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if isSnoozed is changing to false
    }

    // to do, update reminder components
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body or Parameters; Database query failed', error: error.code });
  }
};
const delReminder = require('../utils/delete').deleteReminder;

const deleteReminder = async (req, res) => {
  const reminderId = formatNumber(req.params.reminderId);

  try {
    await delReminder(req, reminderId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.code });
  }
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
