const {
  formatNumber, formatArray,
} = require('../../utils/validateFormat');

const { getReminderQuery, getRemindersQuery } = require('../getFor/getForReminders');
const { createReminderQuery, createRemindersQuery } = require('../createFor/createForReminders');
const { updateReminderQuery, updateRemindersQuery } = require('../updateFor/updateForReminders');
const { deleteReminderQuery, deleteRemindersQuery } = require('../deleteFor/deleteForReminders');
const convertErrorToJSON = require('../../utils/errors/errorFormat');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminders is an array with reminderId that are formatted correctly and request has sufficient permissions to use
*/

const getReminders = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);
  const reminderId = formatNumber(req.params.reminderId);

  // reminderId was provided
  if (reminderId) {
    try {
      const result = await getReminderQuery(req, reminderId);

      if (result.length === 0) {
        // successful but empty array, no reminders to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there were reminders found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      // error when trying to do query to database
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  // no reminderId
  else {
    try {
      const result = await getRemindersQuery(req, dogId);

      if (result.length === 0) {
        // successful but empty array, no reminders to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there were reminders found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      // error when trying to do query to database
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
};

const createReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      const result = await createRemindersQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    // single reminder
    else {
      const result = await createReminderQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      await updateRemindersQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
    // single reminder
    else {
      await updateReminderQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      await deleteRemindersQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
    // single reminder
    else {
      await deleteReminderQuery(req);
      req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
