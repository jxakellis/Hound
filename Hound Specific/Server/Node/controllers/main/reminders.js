const { formatArray } = require('../../utils/database/validateFormat');

const { getReminderQuery, getRemindersQuery } = require('../getFor/getForReminders');
const { createReminderQuery, createRemindersQuery } = require('../createFor/createForReminders');
const { updateReminderQuery, updateRemindersQuery } = require('../updateFor/updateForReminders');
const { deleteReminderQuery, deleteRemindersQuery } = require('../deleteFor/deleteForReminders');
const convertErrorToJSON = require('../../utils/errors/errorFormat');

const { createAlarmNotificationForFamily } = require('../../utils/notification/alarm/createAlarmNotification');
const { deleteAlarmNotificationForReminder } = require('../../utils/notification/alarm/deleteAlarmNotification');

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

  // reminderId was provided
  if (reminderId) {
    try {
      const result = await getReminderQuery(req, reminderId);

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
  }
  // no reminderId
  else {
    try {
      const result = await getRemindersQuery(req, dogId);

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
  }
};

const createReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      const result = await createRemindersQuery(req);
      await req.commitQueries(req);
      // create was successful, so we can create all the alarm notifications
      for (let i = 0; i < result.length; i += 1) {
        const reminder = result[i];
        createAlarmNotificationForFamily(
          req.params.familyId,
          reminder.reminderId,
          'TO DO add dog name',
          reminder.reminderExecutionDate,
          reminder.reminderAction,
          reminder.reminderType,
        );
      }
      return res.status(200).json({ result });
    }
    // single reminder
    else {
      const result = await createReminderQuery(req);
      await req.commitQueries(req);
      const reminder = result[0];
      // create was successful, so we can create the alarm notification
      createAlarmNotificationForFamily(
        req.params.familyId,
        reminder.reminderId,
        'TO DO add dog name',
        reminder.reminderExecutionDate,
        reminder.reminderAction,
        reminder.reminderType,
      );
      return res.status(200).json({ result });
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      const result = await updateRemindersQuery(req);
      await req.commitQueries(req);
      // update was successful, so we can create all new alarm notifications
      for (let i = 0; i < result.length; i += 1) {
        const reminder = result[i];
        createAlarmNotificationForFamily(
          req.params.familyId,
          reminder.reminderId,
          'TO DO add dog name',
          reminder.reminderExecutionDate,
          reminder.reminderAction,
          reminder.reminderType,
        );
      }
      return res.status(200).json({ result: '' });
    }
    // single reminder
    else {
      const result = await updateReminderQuery(req);
      // update was successful, so we can create new alarm notification
      const reminder = result[0];
      createAlarmNotificationForFamily(
        req.params.familyId,
        reminder.reminderId,
        'TO DO add dog name',
        reminder.reminderExecutionDate,
        reminder.reminderAction,
        reminder.reminderType,
      );
      await req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteReminder = async (req, res) => {
  const reminders = formatArray(req.body.reminders);

  try {
    // reminders are provided
    if (reminders) {
      await deleteRemindersQuery(req, reminders);
      // delete was successful, so we can remove all the alarm notifications
      for (let i = 0; i < reminders.length; i += 1) {
        deleteAlarmNotificationForReminder(
          req.params.familyId,
          reminders[i].reminderId,
        );
      }
      await req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
    // single reminder
    else {
      await deleteReminderQuery(req, req.body.reminderId);
      // delete was successful, so we can remove the alarm notification
      deleteAlarmNotificationForReminder(
        req.params.familyId,
        req.body.reminderId,
      );
      await req.commitQueries(req);
      return res.status(200).json({ result: '' });
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getReminders, createReminder, updateReminder, deleteReminder,
};
