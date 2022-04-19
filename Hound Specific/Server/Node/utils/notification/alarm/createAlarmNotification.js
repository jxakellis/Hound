const { queryPromise } = require('../../database/queryPromise');
const { connectionForNotifications } = require('../../../main/databaseConnection');

const { primarySchedule, secondarySchedule } = require('./schedules');

const { formatDate, areAllDefined } = require('../../database/validateFormat');
const { sendAPNNotificationForFamily, sendAPNNotificationForUser } = require('../apn/apnNotification');

const { deleteAlarmNotificationForReminder } = require('./deleteAlarmNotification');

/**
 * For a given reminder for a given family, handles the alarm notifications
 * If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate.
 * If a job with that name from reminderId already exists, then we cancel and replace that job
 * Additionally, handles followUpNotifications for any eligible users with createFollowUpAlarmNotificationForFamily.
 */
const createAlarmNotificationForFamily = async (familyId, reminderId, dogName, reminderExecutionDate, reminderAction, reminderCustomActionName) => {
  // all ids should already be formatted into numbers
  const formattedReminderExecutionDate = formatDate(reminderExecutionDate);
  console.log(`createAlarmNotificationForFamily ${familyId}, ${reminderId}, ${dogName}, ${reminderExecutionDate}, ${formattedReminderExecutionDate}, ${reminderAction}, ${reminderCustomActionName}`);

  try {
    // make sure everything is defined, reminderCustomActionName can be undefined
    if (areAllDefined([familyId, reminderId, dogName, formattedReminderExecutionDate, reminderAction]) === true) {
      // make information for notification
      const primaryAlertTitle = `Reminder for ${dogName}`;
      let primaryAlertBody;
      if (reminderAction === 'Custom' && areAllDefined(reminderCustomActionName)) {
        primaryAlertBody = `Give your dog a helping hand with '${reminderCustomActionName}'`;
      }
      else {
        primaryAlertBody = `Give your dog a helping hand with '${reminderAction}'`;
      }

      // if we are going to overwrite a job, then it should be cancelled first
      await deleteAlarmNotificationForReminder(familyId, reminderId);

      // The date that is further in the future is greater
      // Therefore, if the the present is greater than reminderExecutionDate, that means the reminderExecutionDate is older than the present.

      // reminderExecutionDate is present or in the past, so we should execute immediately
      if (new Date() >= formattedReminderExecutionDate) {
      // no need to await, let it go
        sendAPNNotificationForFamily(familyId, primaryAlertTitle, primaryAlertBody);
        createFollowUpAlarmNotificationForFamily(familyId, reminderId, dogName, formattedReminderExecutionDate, reminderAction, reminderCustomActionName);
      }
      // reminderExecutionDate is in the future
      else {
        primarySchedule.scheduleJob(`Family${familyId}Reminder${reminderId}`, formattedReminderExecutionDate, async () => {
        // no need to await, let it go
          sendAPNNotificationForFamily(familyId, primaryAlertTitle, primaryAlertBody);
          createFollowUpAlarmNotificationForFamily(familyId, reminderId, dogName, formattedReminderExecutionDate, reminderAction, reminderCustomActionName);

          // since we are sending the primary APN notification, now its time to queue the followUp apn notification
        });
      }
    }
  }
  catch (error) {
    console.log(`createFollowUpAlarmNotificationForUser error: ${JSON.stringify(error)}`);
  }
};

/**
 * For a given reminder for a given family, handles the follow up alarm notifications
 * If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate.
 * If a job with that name from reminderId already exists, then we cancel and replace that job
 */
const createFollowUpAlarmNotificationForFamily = async (familyId, reminderId, dogName, reminderExecutionDate, reminderAction, reminderCustomActionName) => {
  const formattedReminderExecutionDate = formatDate(reminderExecutionDate);
  console.log(`createFollowUpAlarmNotificationForFamily ${familyId}, ${reminderId}, ${dogName}, ${reminderExecutionDate}, ${reminderAction}, ${reminderCustomActionName}`);
  try {
    // make sure everything is defined, reminderCustomActionName can be undefined
    if (areAllDefined([familyId, reminderId, dogName, reminderExecutionDate, reminderAction])) {
      // get all the users for a given family that have follow up notifications enabled
      const users = await queryPromise(
        connectionForNotifications,
        'SELECT familyMembers.userId FROM familyMembers LEFT JOIN userConfiguration ON familyMembers.userId = userConfiguration.userId WHERE familyMembers.familyId = ? AND userConfiguration.isFollowUpEnabled = 1',
        [familyId],
      );
      // create follow up notifications for all users that fit the criteria for a follow up
      for (let i = 0; i < users.length; i += 1) {
        // attempt to locate job that has the userId and reminderId  (note: names are in strings, so must convert int to string), we would want to remove that
        const secondaryJob = secondarySchedule.scheduledJobs[`User${users[i].userId}Reminder${reminderId}`];
        if (areAllDefined(secondaryJob) === true) {
          console.log(`Cancelling Secondary Job: ${JSON.stringify(secondaryJob)}`);
          secondaryJob.cancel();
        }
        // no need to await, let it go
        createFollowUpAlarmNotificationForUser(
          users[i].userId,
          reminderId,
          dogName,
          new Date(formattedReminderExecutionDate.getTime() + (users[i].followUpDelay * 1000)),
          reminderAction,
          reminderCustomActionName,
        );
      }
    }
  }
  catch (error) {
    console.log(`createFollowUpAlarmNotificationForFamily error: ${JSON.stringify(error)}`);
  }
};

/**
 * For a given reminder for a given user, handles the follow up alarm notifications
 * If the reminderExecutionDate is in the past, sends APN notification asap. Otherwise, schedule job to send at reminderExecutionDate + followUpDelay.
 * If a job with that name from reminderId already exists, then we cancel and replace that job
 * Once date is reached, job executes to sendAPNNotificationForAll with userId, constructed alertTitle, and constructed alertBody
 */
const createFollowUpAlarmNotificationForUser = async (userId, reminderId, dogName, followUpExecutionDate, reminderAction, reminderCustomActionName) => {
  const formattedFollowUpExecutionDate = formatDate(followUpExecutionDate);
  console.log(`createFollowUpAlarmNotificationForUser ${userId}, ${reminderId}, ${dogName}, ${followUpExecutionDate}, ${formattedFollowUpExecutionDate}, ${reminderAction}, ${reminderCustomActionName}`);

  try {
    // make sure everything is defined, reminderCustomActionName can be undefined
    if (areAllDefined([userId, reminderId, dogName, formattedFollowUpExecutionDate, reminderAction]) === true) {
      // attempt to locate job that has the userId and reminderId  (note: names are in strings, so must convert int to string)
      const job = secondarySchedule.scheduledJobs[`User${userId}Reminder${reminderId}`];
      if (areAllDefined(job) === true) {
        console.log(`Cancelling Secondary Job: ${JSON.stringify(job)}`);
        job.cancel();
      }

      // form secondary alert title and body for follow up notification
      const secondaryAlertTitle = `Follow up reminder for ${dogName}`;
      let secondaryAlertBody;

      if (reminderAction === 'Custom' && areAllDefined(reminderCustomActionName)) {
        secondaryAlertBody = `It's been a bit, remember to give your dog a helping hand with '${reminderCustomActionName}'`;
      }
      else {
        secondaryAlertBody = `It's been a bit, remember to give your dog a helping hand with '${reminderAction}'`;
      }

      // The date that is further in the future is greater
      // Therefore, if the the present is greater than formattedFollowUpExecutionDate, that means the formattedFollowUpExecutionDate is older than the present.

      // formattedFollowUpExecutionDate is present or in the past, so we should execute immediately
      if (new Date() >= formattedFollowUpExecutionDate) {
        // no need to await, let it go
        sendAPNNotificationForUser(userId, secondaryAlertTitle, secondaryAlertBody);
      }
      // formattedFollowUpExecutionDate is in the future
      else {
        secondarySchedule.scheduleJob(`User${userId}Reminder${reminderId}`, formattedFollowUpExecutionDate, () => {
          // no need to await, let it go
          sendAPNNotificationForUser(userId, secondaryAlertTitle, secondaryAlertBody);
        });
      }
    }
  }
  catch (error) {
    console.log(`createFollowUpAlarmNotificationForUser error: ${JSON.stringify(error)}`);
  }
};

module.exports = {
  primarySchedule, secondarySchedule, createAlarmNotificationForFamily, createFollowUpAlarmNotificationForFamily, createFollowUpAlarmNotificationForUser,
};
