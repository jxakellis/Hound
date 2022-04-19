const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

const { primarySchedule, secondarySchedule } = require('./schedules');

const { areAllDefined } = require('../../database/validateFormat');

/**
 * Cancels and deletes any secondary jobs scheduled with the provided userId
 */
const deleteFollowUpAlarmNotificationForUser = async (userId) => {
  console.log(`deleteFollowUpAlarmNotificationForUser ${userId}`);

  try {
    if (areAllDefined(userId) === true) {
      // get all the reminders for the given userId
      const reminderIds = await queryPromise(
        connectionForNotifications,
        'SELECT dogReminder.reminderId FROM dogReminders LEFT JOIN dogs ON dogs.dogId = dogReminders.dogId LEFT JOIN familyMembers ON dogs.familyId = familyMembers.familyId WHERE familyMembers.userId = ? AND dogReminders.reminderExecutionDate IS NOT NULL',
        [userId],
      );

      // iterate through all reminderIds
      for (let i = 0; i < reminderIds.length; i += 1) {
        // if the users have any jobs on the secondary schedule for the reminder, remove them
        const secondaryJob = secondarySchedule.scheduledJobs[`User${userId}Reminder${reminderIds[i].reminderId}`];
        if (areAllDefined(secondaryJob) === true) {
          console.log(`Cancelling Secondary Job: ${JSON.stringify(secondaryJob)}`);
          secondaryJob.cancel();
        }
      }
    }
  }
  catch (error) {
    console.log(`deleteFollowUpAlarmNotificationForUser error: ${JSON.stringify(error)}`);
  }
};

/**
 * Cancels and deletes any primary and secondary job scheduled with the provided reminderId
 */
const deleteAlarmNotificationForReminder = async (familyId, reminderId) => {
  console.log(`deleteAlarmNotificationForReminder ${familyId}, ${reminderId}`);

  try {
    // make sure reminderId is defined
    if (areAllDefined(familyId, reminderId) === true) {
    // attempt to locate job that has the familyId and reminderId
      const primaryJob = primarySchedule.scheduledJobs[`Family${familyId}Reminder${reminderId}`];
      if (areAllDefined(primaryJob) === true) {
        console.log(`Cancelling Primary Job: ${JSON.stringify(primaryJob)}`);
        primaryJob.cancel();
      }
      // finds all the users in the family
      const users = await queryPromise(
        connectionForNotifications,
        'SELECT userId FROM familyMembers WHERE familyId = ?',
        [familyId],
      );
      // iterate through all users for the family
      for (let i = 0; i < users.length; i += 1) {
      // if the users have any jobs on the secondary schedule for the reminder, remove them
        const secondaryJob = secondarySchedule.scheduledJobs[`User${users[i].userId}Reminder${reminderId}`];
        if (areAllDefined(secondaryJob) === true) {
          console.log(`Cancelling Secondary Job: ${JSON.stringify(secondaryJob)}`);
          secondaryJob.cancel();
        }
      }
    }
  }
  catch (error) {
    console.log(`deleteAlarmNotificationForReminder error: ${JSON.stringify(error)}`);
  }
};

/**
 * Cancels and deletes any promary and secondary job scheduled with the provided familyId
 */
/*
const deleteAllAlarmNotificationForFamily = async (familyId) => {
  console.log(`deleteAllAlarmNotificationForFamily ${familyId}`);

  try {
    if (areAllDefined(familyId) === true) {
      // get all the reminders for the given familyId, don't exclude any.
      const reminderIds = await queryPromise(
        connectionForNotifications,
        'SELECT dogReminders.reminderId FROM dogReminders LEFT JOIN dogs ON dogs.dogId = dogReminders.dogId WHERE dogs.familyId = ? AND dogReminders.reminderExecutionDate IS NOT NULL',
        [familyId],
      );

      // cancel the notifications for the reminder
      for (let i = 0; i < reminderIds.length; i += 1) {
        await deleteAlarmNotificationForReminder(familyId, reminderIds[i].reminderId);
      }
    }
  }
  catch (error) {
    console.log(`deleteAllAlarmNotificationForFamily error: ${JSON.stringify(error)}`);
  }
};
*/

module.exports = {
  primarySchedule, secondarySchedule, deleteAlarmNotificationForReminder, deleteFollowUpAlarmNotificationForUser,
};
