const { alarmLogger } = require('../../logging/loggers');
const { queryPromise } = require('../../database/queryPromise');
const { connectionForAlarms } = require('../../database/databaseConnection');

const { schedule } = require('./schedules');

const { formatDate, areAllDefined } = require('../../validation/validateFormat');
const { sendAPNForFamily, sendAPNForUser } = require('../apn/sendAPN');

const { deleteAlarmNotificationsForReminder } = require('./deleteAlarmNotification');
const { cancelSecondaryJobForUserForReminder } = require('./cancelJob');

/**
 * For a given reminder for a given family, handles the alarm notifications
 * If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate.
 * If a job with that name from reminderId already exists, then we cancel and replace that job
 * Additionally, handles secondaryAlarmNotification for any eligible users with createSecondaryAlarmNotificationForFamily.
 */
const createAlarmNotificationForFamily = async (familyId, reminderId, reminderExecutionDate) => {
  // all ids should already be formatted into numbers
  const formattedReminderExecutionDate = formatDate(reminderExecutionDate);
  alarmLogger.debug(`createAlarmNotificationForFamily ${familyId}, ${reminderId}, ${reminderExecutionDate}, ${formattedReminderExecutionDate}`);

  try {
    if (areAllDefined(familyId, reminderId) === false) {
      return;
    }

    // We are potentially overriding a job, so we must cancel it first
    await deleteAlarmNotificationsForReminder(familyId, reminderId);

    // If a user updates a reminder, this function is invoked. When a reminder is updated, is reminderExecutionDate can be undefined
    // Therefore we want to delete the old alarm notifications for that reminder and (if it has a reminderExecutionDate) create new alarm notifications
    if (areAllDefined(formattedReminderExecutionDate) === false) {
      return;
    }
    // The date that is further in the future is greater
    // Therefore, if the the present is greater than reminderExecutionDate, that means the reminderExecutionDate is older than the present.

    // reminderExecutionDate is present or in the past, so we should execute immediately
    if (new Date() >= formattedReminderExecutionDate) {
      // do these async, no need to await
      sendPrimaryAPNAndCreateSecondaryAlarmNotificationForFamily(familyId, reminderId);
    }
    // reminderExecutionDate is in the future
    else {
      alarmLogger.info(`Scheduling a new job; count will be ${Object.keys(schedule.scheduledJobs).length + 1}`);
      schedule.scheduleJob(`Family${familyId}Reminder${reminderId}`, formattedReminderExecutionDate, async () => {
        // do these async, no need to await
        sendPrimaryAPNAndCreateSecondaryAlarmNotificationForFamily(familyId, reminderId);
      });
    }
  }
  catch (error) {
    alarmLogger.error('createAlarmNotificationForFamily error:');
    alarmLogger.error(error);
  }
};

/**
 * Helper method for createAlarmNotificationForFamily, actually queries database to get most updated version of dog and reminder.
 * Physically sends the primary APN then createSecondaryAlarmNotificationForUser for all eligible users in the family
 */
const sendPrimaryAPNAndCreateSecondaryAlarmNotificationForFamily = async (familyId, reminderId) => {
  try {
    // get the dogName, reminderAction, and reminderCustomActionName for the given reminderId
    // the reminderId has to exist to search and we check to make sure the dogId isn't null (to make sure the dog still exists too)
    const reminderWithInfo = await queryPromise(
      connectionForAlarms,
      'SELECT dogs.dogName, dogReminders.reminderId, dogReminders.reminderExecutionDate, dogReminders.reminderAction, dogReminders.reminderCustomActionName FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogReminders.reminderId = ? AND dogReminders.reminderExecutionDate IS NOT NULL AND dogs.dogId IS NOT NULL LIMIT 18446744073709551615',
      [reminderId],
    );
    const reminder = reminderWithInfo[0];

    // Check to make sure the required information of the reminder exists
    if (areAllDefined(reminder, reminder.dogName, reminder.reminderId, reminder.reminderAction) === false) {
      return;
    }

    // make information for notification
    const primaryAlertTitle = `Reminder for ${reminder.dogName}`;
    let primaryAlertBody;
    if (reminder.reminderAction === 'Custom' && areAllDefined(reminder.reminderCustomActionName) && reminder.reminderCustomActionName !== '') {
      primaryAlertBody = `Give your dog a helping hand with '${reminder.reminderCustomActionName}'`;
    }
    else {
      primaryAlertBody = `Give your dog a helping hand with '${reminder.reminderAction}'`;
    }

    // send immediate APN notification for family
    sendAPNForFamily(familyId, 'reminder', primaryAlertTitle, primaryAlertBody);

    // createSecondaryAlarmNotificationForFamily, handles the secondary alarm notifications
    // If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate.
    // If a job with that name from reminderId already exists, then we cancel and replace that job

    // get all the users for a given family that have secondary notifications enabled
    // if familyId is missing, we will have no results. If a userConfiguration is missing, then there will be no userId for that user in the results
    const users = await queryPromise(
      connectionForAlarms,
      'SELECT familyMembers.userId, userConfiguration.followUpDelay FROM familyMembers JOIN userConfiguration ON familyMembers.userId = userConfiguration.userId WHERE familyMembers.familyId = ? AND userConfiguration.isFollowUpEnabled = 1 LIMIT 18446744073709551615',
      [familyId],
    );

    // create secondary notifications for all users that fit the criteria for a secondary
    for (let i = 0; i < users.length; i += 1) {
      cancelSecondaryJobForUserForReminder(users[i].userId, reminderId);
      // no need to await, let it go
      createSecondaryAlarmNotificationForUser(
        users[i].userId,
        reminder.reminderId,
        new Date(formatDate(reminder.reminderExecutionDate).getTime() + (users[i].followUpDelay * 1000)),
      );
    }
  }
  catch (error) {
    alarmLogger.error('sendPrimaryAPNAndCreateSecondaryNotificationForFamily error:');
    alarmLogger.error(error);
  }
};

/**
 * Doesn't check for isFollowUpEnabled status, so ensure the user is enabled
 * For a given reminder for a given user, handles the secondary alarm notifications
 * If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate + followUpDelay.
 * If a job with that name from reminderId already exists, then we cancel and replace that job
 * Once date is reached, job executes to sendAPNForAll with userId, constructed alertTitle, and constructed alertBody
 */
const createSecondaryAlarmNotificationForUser = async (userId, reminderId, secondaryExecutionDate) => {
  const formattedSecondaryExecutionDate = formatDate(secondaryExecutionDate);
  alarmLogger.debug(`createSecondaryAlarmNotificationForUser ${userId}, ${reminderId}, ${secondaryExecutionDate}, ${formattedSecondaryExecutionDate}`);

  try {
    // make sure the required parameters are defined
    if (areAllDefined(userId, reminderId) === false) {
      return;
    }

    cancelSecondaryJobForUserForReminder(userId, reminderId);

    if (areAllDefined(formattedSecondaryExecutionDate) === false) {
      return;
    }
    // The date that is further in the future is greater
    // Therefore, if the the present is greater than formattedSecondaryExecutionDate, that means the formattedSecondaryExecutionDate is older than the present.

    // formattedSecondaryExecutionDate is present or in the past, so we should execute immediately
    if (new Date() >= formattedSecondaryExecutionDate) {
      // no need to await, let it go
      sendSecondaryAPNForUser(userId, reminderId);
    }
    // formattedSecondaryExecutionDate is in the future
    else {
      alarmLogger.info(`Scheduling a new job; count will be ${Object.keys(schedule.scheduledJobs).length + 1}`);
      schedule.scheduleJob(`User${userId}Reminder${reminderId}`, formattedSecondaryExecutionDate, () => {
        // no need to await, let it go
        sendSecondaryAPNForUser(userId, reminderId);
      });
    }
  }
  catch (error) {
    alarmLogger.error('createSecondaryAlarmNotificationForUser error:');
    alarmLogger.error(error);
  }
};

/**
 * Helper method for createSecondaryAlarmNotificationForUser, actually queries database to get most updated version of dog and reminder.
 * Physically sends the secondary APN notification
 */
const sendSecondaryAPNForUser = async (userId, reminderId) => {
  try {
    // get the dogName, reminderAction, and reminderCustomActionName for the given reminderId
    // the reminderId has to exist to search and we check to make sure the dogId isn't null (to make sure the dog still exists too)
    const reminderWithInfo = await queryPromise(
      connectionForAlarms,
      'SELECT dogs.dogName, dogReminders.reminderAction, dogReminders.reminderCustomActionName FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogReminders.reminderId = ? AND dogReminders.reminderExecutionDate IS NOT NULL AND dogs.dogId IS NOT NULL LIMIT 18446744073709551615',
      [reminderId],
    );
    const reminder = reminderWithInfo[0];

    // check for the reminder and needed properties existance
    if (areAllDefined(reminder, reminder.dogName, reminder.reminderAction) === false) {
      return;
    }

    // form secondary alert title and body for secondary notification
    const secondaryAlertTitle = `Follow up reminder for ${reminder.dogName}`;
    let secondaryAlertBody;

    if (reminder.reminderAction === 'Custom' && areAllDefined(reminder.reminderCustomActionName) && reminder.reminderCustomActionName !== '') {
      secondaryAlertBody = `It's been a bit, remember to give your dog a helping hand with '${reminder.reminderCustomActionName}'`;
    }
    else {
      secondaryAlertBody = `It's been a bit, remember to give your dog a helping hand with '${reminder.reminderAction}'`;
    }

    sendAPNForUser(userId, 'reminder', secondaryAlertTitle, secondaryAlertBody);
  }
  catch (error) {
    alarmLogger.error('sendAPNForUser error:');
    alarmLogger.error(error);
  }
};

// Don't export sendPrimaryAPNAndCreateSecondaryAlarmNotificationForFamily or sendSecondaryAPNForUser as they are helper methods
module.exports = {
  createAlarmNotificationForFamily, createSecondaryAlarmNotificationForUser,
};
