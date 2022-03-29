const {
  formatNumber, formatArray,
} = require('../../utils/validateFormat');

const { getReminderQuery, getRemindersQuery } = require('../getFor/getForReminders');
const { createReminderQuery, createRemindersQuery } = require('../createFor/createForReminders');
const { updateReminderQuery, updateRemindersQuery } = require('../updateFor/updateForReminders');
const { deleteReminderQuery, deleteRemindersQuery } = require('../deleteFor/deleteForReminders');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminders is an array with reminderId that are formatted correctly and request has sufficient permissions to use
*/

const getReminders = async (req, res) => {
  const reminderId = formatNumber(req.params.reminderId);

  // reminderId was provided
  if (reminderId) {
    return getReminderQuery(req, res);
  }
  // no reminderId
  else {
    return getRemindersQuery(req, res);
  }
};

const createReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);
  // reminders are provided
  if (reminders) {
    return createRemindersQuery(req, res);
  }
  // single reminder
  else {
    return createReminderQuery(req, res);
  }
};

const updateReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);
  // reminders are provided
  if (reminders) {
    return updateRemindersQuery(req, res);
  }
  // single reminder
  else {
    return updateReminderQuery(req, res);
  }
};

const deleteReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);
  // reminders is provided
  if (reminders) {
    return deleteRemindersQuery(req, res);
  }
  else {
    return deleteReminderQuery(req, res);
  }
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
