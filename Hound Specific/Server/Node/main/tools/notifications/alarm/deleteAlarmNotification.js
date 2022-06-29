const { alarmLogger } = require('../../logging/loggers');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForAlarms } = require('../../database/databaseConnection');
const { IS_PRODUCTION } = require('../../../server/constants');

const { areAllDefined } = require('../../format/validateDefined');
const { cancelPrimaryJobForFamilyForReminder, cancelSecondaryJobForUserForReminder } = require('./cancelJob');

const deleteAlarmNotificationsForFamily = async (familyId) => {
  try {
    if (IS_PRODUCTION === false) {
      alarmLogger.debug(`deleteAlarmNotificationsForFamily ${familyId}`);
    }

    // make sure reminderId is defined
    if (areAllDefined(familyId) === false) {
      return;
    }

    // get all the reminders for the family
    const reminders = await queryPromise(
      connectionForAlarms,
      'SELECT reminderId FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND dogs.familyId = ? LIMIT 18446744073709551615',
      [familyId],
    );
      // finds all the users in the family
    const users = await queryPromise(
      connectionForAlarms,
      'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
      [familyId],
    );

    for (let i = 0; i < reminders.length; i += 1) {
      const reminderId = reminders[i].reminderId;
      cancelPrimaryJobForFamilyForReminder(familyId, reminderId);

      // iterate through all users for the family
      for (let j = 0; j < users.length; j += 1) {
        const userId = users[j].userId;
        // if the users have any jobs on the secondary schedule for the reminder, remove them
        cancelSecondaryJobForUserForReminder(userId, reminderId);
      }
    }
  }
  catch (error) {
    alarmLogger.error('deleteAlarmNotificationsForFamily error:');
    alarmLogger.error(error);
  }
};

/**
 * Cancels and deletes any primary and secondary job scheduled with the provided reminderId
 */
const deleteAlarmNotificationsForReminder = async (familyId, reminderId) => {
  try {
    if (IS_PRODUCTION === false) {
      alarmLogger.debug(`deleteAlarmNotificationsForReminder ${familyId}, ${reminderId}`);
    }

    // make sure reminderId is defined
    if (areAllDefined(familyId, reminderId) === false) {
      return;
    }

    cancelPrimaryJobForFamilyForReminder(familyId, reminderId);

    // finds all the users in the family
    const users = await queryPromise(
      connectionForAlarms,
      'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
      [familyId],
    );
      // iterate through all users for the family
    for (let i = 0; i < users.length; i += 1) {
      // if the users have any jobs on the secondary schedule for the reminder, remove them
      cancelSecondaryJobForUserForReminder(users[i].userId, reminderId);
    }
  }
  catch (error) {
    alarmLogger.error('deleteAlarmNotificationsForReminder error:');
    alarmLogger.error(error);
  }
};

/**
 * Cancels and deletes any secondary jobs scheduled with the provided userId
 */
const deleteSecondaryAlarmNotificationsForUser = async (userId) => {
  try {
    if (IS_PRODUCTION === false) {
      alarmLogger.debug(`deleteSecondaryAlarmNotificationsForUser ${userId}`);
    }

    if (areAllDefined(userId) === false) {
      return;
    }
    // get all the reminders for the given userId
    // specifically use JOIN to excluse resulst where reminder, dog, family, or family member are missing
    const reminderIds = await queryPromise(
      connectionForAlarms,
      'SELECT dogReminders.reminderId FROM dogReminders JOIN dogs ON dogs.dogId = dogReminders.dogId JOIN familyMembers ON dogs.familyId = familyMembers.familyId WHERE dogs.dogIsDeleted = 0 AND dogReminders.reminderIsDeleted = 0 AND familyMembers.userId = ? AND dogReminders.reminderExecutionDate IS NOT NULL LIMIT 18446744073709551615',
      [userId],
    );

    // iterate through all reminderIds
    for (let i = 0; i < reminderIds.length; i += 1) {
      // if the users have any jobs on the secondary schedule for the reminder, remove them
      cancelSecondaryJobForUserForReminder(userId, reminderIds[i].reminderId);
    }
  }
  catch (error) {
    alarmLogger.error('deleteSecondaryAlarmNotificationsForUser error:');
    alarmLogger.error(error);
  }
};

module.exports = {
  deleteAlarmNotificationsForFamily, deleteAlarmNotificationsForReminder, deleteSecondaryAlarmNotificationsForUser,
};
