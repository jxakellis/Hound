const { formatArray } = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { getReminderForReminderId, getAllRemindersForDogId } = require('../getFor/getForReminders');
const { createReminderForDogIdReminder, createRemindersForDogIdReminders } = require('../createFor/createForReminders');
const { updateReminderForDogIdReminder, updateRemindersForDogIdReminders } = require('../updateFor/updateForReminders');
const { deleteReminderForFamilyIdDogIdReminderId } = require('../deleteFor/deleteForReminders');
const { convertErrorToJSON } = require('../../main/tools/general/errors');

const { createAlarmNotificationForFamily } = require('../../main/tools/notifications/alarm/createAlarmNotification');

/*
Known:
- familyId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminders is an array with reminderId that are formatted correctly and request has sufficient permissions to use
*/

async function getReminders(req, res) {
  try {
    const { dogId, reminderId } = req.params;
    const { lastDogManagerSynchronization } = req.query;

    const result = areAllDefined(reminderId)
    // reminderId was provided, look for single reminder
      ? await getReminderForReminderId(req, reminderId, lastDogManagerSynchronization)
    // look for multiple reminders
      : await getAllRemindersForDogId(req, dogId, lastDogManagerSynchronization);

    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    // error when trying to do query to database
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function createReminder(req, res) {
  try {
    const { familyId, dogId } = req.params;
    const reminder = req.body;
    const reminders = formatArray(req.body.reminders);
    const result = areAllDefined(reminders) ? await createRemindersForDogIdReminders(req, dogId, reminders) : [await createReminderForDogIdReminder(req, dogId, reminder)];

    await req.commitQueries(req);
    // create was successful, so we can create all the alarm notifications
    for (let i = 0; i < result.length; i += 1) {
      createAlarmNotificationForFamily(
        familyId,
        result[i].reminderId,
        result[i].reminderExecutionDate,
      );
    }
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function updateReminder(req, res) {
  try {
    const { familyId, dogId } = req.params;
    const reminder = req.body;
    const reminders = formatArray(req.body.reminders);

    const result = areAllDefined(reminders) ? await updateRemindersForDogIdReminders(req, dogId, reminders) : await updateReminderForDogIdReminder(req, dogId, reminder);

    await req.commitQueries(req);
    // update was successful, so we can create all new alarm notifications
    for (let i = 0; i < result.length; i += 1) {
      createAlarmNotificationForFamily(
        familyId,
        result[i].reminderId,
        result[i].reminderExecutionDate,
      );
    }
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function deleteReminder(req, res) {
  try {
    const { familyId, dogId } = req.params;
    const { reminderId } = req.body;
    const reminders = formatArray(req.body.reminders);

    // reminders array
    if (areAllDefined(reminders)) {
      const promises = [];
      for (let i = 0; i < reminders.length; i += 1) {
        promises.push(deleteReminderForFamilyIdDogIdReminderId(req, familyId, dogId, reminders[i].reminderId));
      }
      await Promise.all(promises);
    }
    // single reminder
    else {
      await deleteReminderForFamilyIdDogIdReminderId(req, familyId, dogId, reminderId);
    }

    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
