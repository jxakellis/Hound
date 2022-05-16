const { formatArray, areAllDefined } = require('../../main/tools/validation/validateFormat');

const { getReminderQuery, getRemindersQuery } = require('../getFor/getForReminders');
const { createReminderQuery, createRemindersQuery } = require('../createFor/createForReminders');
const { updateReminderQuery, updateRemindersQuery } = require('../updateFor/updateForReminders');
const { deleteReminderQuery, deleteRemindersQuery } = require('../deleteFor/deleteForReminders');
const convertErrorToJSON = require('../../main/tools/errors/errorFormat');

const { createAlarmNotificationForFamily } = require('../../main/tools/notifications/alarm/createAlarmNotification');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminders is an array with reminderId that are formatted correctly and request has sufficient permissions to use
*/

const getReminders = async (req, res) => {
  const dogId = req.params.dogId;
  const reminderId = req.params.reminderId;

  let result;

  try {
    // reminderId was provided, look for single reminder
    if (areAllDefined(reminderId)) {
      result = await getReminderQuery(req, reminderId);
    }
    // look for multiple reminders
    else {
      result = await getRemindersQuery(req, dogId);
    }
  }
  catch (error) {
    // error when trying to do query to database
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }

  if (result.length === 0) {
    // successful but empty array, no reminders to return
    await req.commitQueries(req);
    return res.status(200).json({ result: [] });
  }
  else {
    // array has items, meaning there were reminders found, successful!
    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
};

const createReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  let result;
  try {
    // reminders are provided
    if (areAllDefined(reminders)) {
      // array of reminders JSON
      // [{reminderInfo1}, {reminderInfo2}...]
      result = await createRemindersQuery(req, reminders);
    }
    // single reminder
    else {
      // convert single reminder JSON into an array with a single reminder
      // { reminderInfo1 } => [{reminderInfo1}]
      result = [await createReminderQuery(req, req.body)];
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }

  await req.commitQueries(req);
  // create was successful, so we can create all the alarm notifications
  for (let i = 0; i < result.length; i += 1) {
    const reminder = result[i];
    createAlarmNotificationForFamily(
      req.params.familyId,
      reminder.reminderId,
      reminder.reminderExecutionDate,
    );
  }
  return res.status(200).json({ result });
};

const updateReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  let result;

  try {
    // reminders array is provided
    if (areAllDefined(reminders)) {
      result = await updateRemindersQuery(req, reminders);
    }
    // just a single reminder
    else {
      result = await updateReminderQuery(req, req.body);
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }

  await req.commitQueries(req);
  // update was successful, so we can create all new alarm notifications
  for (let i = 0; i < result.length; i += 1) {
    const reminder = result[i];
    createAlarmNotificationForFamily(
      req.params.familyId,
      reminder.reminderId,
      reminder.reminderExecutionDate,
    );
  }
  return res.status(200).json({ result: '' });
};

const deleteReminder = async (req, res) => {
  const familyId = req.params.familyId;
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders array
    if (areAllDefined(reminders)) {
      await deleteRemindersQuery(req, familyId, reminders);
    }
    // single reminder
    else {
      await deleteReminderQuery(req, familyId, req.body.reminderId);
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }

  await req.commitQueries(req);
  return res.status(200).json({ result: '' });
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
