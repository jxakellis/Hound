const { formatArray } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { getReminderForReminderId, getAllRemindersForDogId } = require('../getFor/getForReminders');
const { createReminderForDogIdReminder, createRemindersForDogIdReminders } = require('../createFor/createForReminders');
const { updateReminderForReminder, updateRemindersForReminders } = require('../updateFor/updateForReminders');
const { deleteReminderForFamilyIdDogIdReminderId } = require('../deleteFor/deleteForReminders');
const { convertErrorToJSON } = require('../../main/tools/errors/errorFormat');

const { createAlarmNotificationForFamily } = require('../../main/tools/notifications/alarm/createAlarmNotification');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminders is an array with reminderId that are formatted correctly and request has sufficient permissions to use
*/

const getReminders = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    const reminderId = req.params.reminderId;

    let result;
    // reminderId was provided, look for single reminder
    if (areAllDefined(reminderId)) {
      result = await getReminderForReminderId(req, reminderId);
    }
    // look for multiple reminders
    else {
      result = await getAllRemindersForDogId(req, dogId);
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
  }
  catch (error) {
    // error when trying to do query to database
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const createReminder = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    const reminders = formatArray(req.body.reminders);
    let result;
    // reminders are provided
    if (areAllDefined(reminders)) {
      // array of reminders JSON
      // [{reminderInfo1}, {reminderInfo2}...]
      result = await createRemindersForDogIdReminders(req, dogId, reminders);
    }
    // single reminder
    else {
      // convert single reminder JSON into an array with a single reminder
      // { reminderInfo1 } => [{reminderInfo1}]
      result = [await createReminderForDogIdReminder(req, dogId, req.body)];
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
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateReminder = async (req, res) => {
  try {
    const reminders = formatArray(req.body.reminders);

    let result;
    // reminders array is provided
    if (areAllDefined(reminders)) {
      result = await updateRemindersForReminders(req, reminders);
    }
    // just a single reminder
    else {
      result = await updateReminderForReminder(req, req.body);
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
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteReminder = async (req, res) => {
  try {
    const familyId = req.params.familyId;
    const dogId = req.params.dogId;
    const reminders = formatArray(req.body.reminders);

    // reminders array
    if (areAllDefined(reminders)) {
      for (let i = 0; i < reminders.length; i += 1) {
        const reminderId = reminders[i].reminderId;
        await deleteReminderForFamilyIdDogIdReminderId(req, familyId, dogId, reminderId);
      }
    }
    // single reminder
    else {
      await deleteReminderForFamilyIdDogIdReminderId(req, familyId, dogId, req.body.reminderId);
    }

    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
