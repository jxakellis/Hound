const { alarmLogger } = require('../../logging/pino');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

const { schedule } = require('./schedules');

const { areAllDefined } = require('../../database/validateFormat');

const deleteAlarmNotificationsForFamily = async (familyId) => {
  alarmLogger.debug(`deleteAlarmNotificationsForFamily ${familyId}`);

  try {
    // make sure reminderId is defined
    if (areAllDefined(familyId) === true) {
      // get all the reminders for the family
      const reminders = await queryPromise(
        connectionForNotifications,
        'SELECT reminderId FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.familyId = ? LIMIT 18446744073709551615',
        [familyId],
      );
      // finds all the users in the family
      const users = await queryPromise(
        connectionForNotifications,
        'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
        [familyId],
      );

      for (let i = 0; i < reminders.length; i += 1) {
        const reminderId = reminders[i].reminderId;
        // attempt to locate job that has the familyId and reminderId
        const primaryJob = schedule.scheduledJobs[`Family${familyId}Reminder${reminderId}`];
        if (areAllDefined(primaryJob) === true) {
          alarmLogger.debug(`Cancelling Primary Job: ${primaryJob.name}`);
          primaryJob.cancel();
        }

        // iterate through all users for the family
        for (let j = 0; j < users.length; j += 1) {
          const userId = users[j].userId;
          // if the users have any jobs on the secondary schedule for the reminder, remove them
          const secondaryJob = schedule.scheduledJobs[`User${userId}Reminder${reminderId}`];
          if (areAllDefined(secondaryJob) === true) {
            alarmLogger.debug(`Cancelling Secondary Job: ${secondaryJob.name}`);
            secondaryJob.cancel();
          }
        }
      }
    }
  }
  catch (error) {
    alarmLogger.error(`deleteAlarmNotificationsForFamily error: ${JSON.stringify(error)}`);
  }
};

/**
 * Cancels and deletes any primary and secondary job scheduled with the provided reminderId
 */
const deleteAlarmNotificationsForReminder = async (familyId, reminderId) => {
  alarmLogger.debug(`deleteAlarmNotificationsForReminder ${familyId}, ${reminderId}`);

  try {
    // make sure reminderId is defined
    if (areAllDefined([familyId, reminderId]) === true) {
    // attempt to locate job that has the familyId and reminderId
      const primaryJob = schedule.scheduledJobs[`Family${familyId}Reminder${reminderId}`];
      if (areAllDefined(primaryJob) === true) {
        alarmLogger.debug(`Cancelling Primary Job: ${primaryJob.name}`);
        primaryJob.cancel();
      }
      // finds all the users in the family
      const users = await queryPromise(
        connectionForNotifications,
        'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
        [familyId],
      );
      // iterate through all users for the family
      for (let i = 0; i < users.length; i += 1) {
      // if the users have any jobs on the secondary schedule for the reminder, remove them
        const secondaryJob = schedule.scheduledJobs[`User${users[i].userId}Reminder${reminderId}`];
        if (areAllDefined(secondaryJob) === true) {
          alarmLogger.debug(`Cancelling Secondary Job: ${secondaryJob.name}`);
          secondaryJob.cancel();
        }
      }
    }
  }
  catch (error) {
    alarmLogger.error(`deleteAlarmNotificationsForReminder error: ${JSON.stringify(error)}`);
  }
};

/**
 * Cancels and deletes any secondary jobs scheduled with the provided userId
 */
const deleteSecondaryAlarmNotificationsForUser = async (userId) => {
  alarmLogger.debug(`deleteSecondaryAlarmNotificationsForUser ${userId}`);

  try {
    if (areAllDefined(userId) === true) {
      // get all the reminders for the given userId
      // specifically use JOIN to excluse resulst where reminder, dog, family, or family member are missing
      const reminderIds = await queryPromise(
        connectionForNotifications,
        'SELECT dogReminder.reminderId FROM dogReminders JOIN dogs ON dogs.dogId = dogReminders.dogId JOIN familyMembers ON dogs.familyId = familyMembers.familyId WHERE familyMembers.userId = ? AND dogReminders.reminderExecutionDate IS NOT NULL LIMIT 18446744073709551615',
        [userId],
      );

      // iterate through all reminderIds
      for (let i = 0; i < reminderIds.length; i += 1) {
        // if the users have any jobs on the secondary schedule for the reminder, remove them
        const secondaryJob = schedule.scheduledJobs[`User${userId}Reminder${reminderIds[i].reminderId}`];
        if (areAllDefined(secondaryJob) === true) {
          alarmLogger.debug(`Cancelling Secondary Job: ${secondaryJob.name}`);
          secondaryJob.cancel();
        }
      }
    }
  }
  catch (error) {
    alarmLogger.error(`deleteSecondaryAlarmNotificationsForUser error: ${JSON.stringify(error)}`);
  }
};

module.exports = {
  deleteAlarmNotificationsForFamily, deleteAlarmNotificationsForReminder, deleteSecondaryAlarmNotificationsForUser,
};
