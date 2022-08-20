const { ValidationError } = require('../../main/tools/general/errors');

const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatBoolean, formatDate, formatSHA256Hash, formatString,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

const { createFamilyMemberJoinNotification } = require('../../main/tools/notifications/alert/createFamilyNotification');
const { getAllFamilyMembersForFamilyId, getFamilyMemberUserIdForUserId } = require('../getFor/getForFamily');
const { getActiveInAppSubscriptionForFamilyId } = require('../getFor/getForInAppSubscriptions');

const { createFamilyLockedNotification, createFamilyPausedNotification } = require('../../main/tools/notifications/alert/createFamilyNotification');
const { deleteAlarmNotificationsForFamily } = require('../../main/tools/notifications/alarm/deleteAlarmNotification');

/**
 *  Queries the database to update a family to add a new user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
async function updateFamilyForUserIdFamilyId(databaseConnection, userId, familyId, forFamilyCode, forIsLocked, forIsPaused) {
  const familyCode = formatString(forFamilyCode);
  const isLocked = formatBoolean(forIsLocked);
  const isPaused = formatBoolean(forIsPaused);

  if (areAllDefined(databaseConnection, userId) === false) {
    throw new ValidationError('databaseConnection or userId missing', global.constant.error.value.MISSING);
  }

  // familyId doesn't exist, so user must want to join a family
  if (areAllDefined(familyId) === false && areAllDefined(familyCode)) {
    await addFamilyMember(databaseConnection, userId, familyCode);
  }
  else if (areAllDefined(isLocked)) {
    await updateIsLocked(databaseConnection, userId, familyId, isLocked);
  }
  else if (areAllDefined(isPaused)) {
    await updateIsPaused(databaseConnection, userId, familyId, isPaused);
  }
  else {
    throw new ValidationError('No value provided', global.constant.error.value.MISSING);
  }
}

/**
 * Helper method for createFamilyForUserId, goes through checks to attempt to add user to desired family
 */
async function addFamilyMember(databaseConnection, userId, forFamilyCode) {
  // make sure familyCode was provided
  let familyCode = formatString(forFamilyCode);

  if (areAllDefined(databaseConnection, userId, familyCode) === false) {
    throw new ValidationError('databaseConnection, userId, or familyCode missing', global.constant.error.value.MISSING);
  }
  familyCode = familyCode.toUpperCase();

  // retrieve information about the family linked to the familyCode
  let family = await databaseQuery(
    databaseConnection,
    'SELECT familyId, isLocked FROM families WHERE familyCode = ? LIMIT 1',
    [familyCode],
  );

  // make sure the familyCode was valid by checking if it matched a family
  if (family.length === 0) {
    // result length is zero so there are no families with that familyCode
    throw new ValidationError('familyCode invalid, not found', global.constant.error.family.join.FAMILY_CODE_INVALID);
  }
  [family] = family;
  const familyId = formatSHA256Hash(family.familyId);
  const isLocked = formatBoolean(family.isLocked);
  // familyCode exists and is linked to a family, now check if family is locked against new members
  if (isLocked) {
    throw new ValidationError('Family is locked', global.constant.error.family.join.FAMILY_LOCKED);
  }

  // the familyCode is valid and linked to an UNLOCKED family

  const isFamilyMember = await getFamilyMemberUserIdForUserId(databaseConnection, userId);

  if (isFamilyMember.length !== 0) {
    // user is already in a family
    throw new ValidationError('You are already in a family', global.constant.error.family.join.IN_FAMILY_ALREADY);
  }

  // Don't use .activeSubscription property: the property wasn't assigned to the request due to the user not being in a family (only assigned with familyId is path param)
  const activeSubscription = await getActiveInAppSubscriptionForFamilyId(databaseConnection, familyId);
  const familyMembers = await getAllFamilyMembersForFamilyId(databaseConnection, familyId);

  // the family is either at the limit of family members is exceeds the limit, therefore no new users can join
  if (familyMembers.length >= activeSubscription.numberOfFamilyMembers) {
    throw new ValidationError(`Family member limit of ${activeSubscription.numberOfFamilyMembers} exceeded`, global.constant.error.family.limit.FAMILY_MEMBER_TOO_LOW);
  }

  // familyCode validated and user is not a family member in any family
  // insert the user into the family as a family member.
  await databaseQuery(
    databaseConnection,
    'INSERT INTO familyMembers(userId, familyId) VALUES (?, ?)',
    [userId, familyId],
  );

  createFamilyMemberJoinNotification(userId, family.familyId);
}

/**
 * Helper method for updateFamilyForFamilyId, switches the family isLocked status
 */
async function updateIsLocked(databaseConnection, userId, familyId, forIsLocked) {
  const isLocked = formatBoolean(forIsLocked);

  if (areAllDefined(databaseConnection, userId, familyId, isLocked) === false) {
    throw new ValidationError('databaseConnection, userId, familyId, or isLocked missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    databaseConnection,
    'UPDATE families SET isLocked = ? WHERE familyId = ?',
    [isLocked, familyId],
  );

  createFamilyLockedNotification(userId, familyId, isLocked);
}

/**
 * Helper method for updateFamilyForFamilyId, goes through all of the logic to update isPaused, lastPause, lastUnpause
 * If pausing, saves all intervalElapsed, sets all reminderExecutionDates to nil, and deleteAlarmNotifications
 * If unpausing, sets reminderExecutionBasis to Date(). The new reminderExecutionDates must be calculated by the user and sent to the server
 */
async function updateIsPaused(databaseConnection, userId, familyId, forIsPaused) {
  const isPaused = formatBoolean(forIsPaused);

  if (areAllDefined(databaseConnection, userId, familyId, isPaused) === false) {
    throw new ValidationError('databaseConnection, userId, familyId, or isPaused missing', global.constant.error.value.MISSING);
  }

  // find out the family's current pause status
  let familyConfiguration = await databaseQuery(
    databaseConnection,
    'SELECT isPaused, lastPause, lastUnpause FROM families WHERE familyId = ? LIMIT 1',
    [familyId],
  );
  [familyConfiguration] = familyConfiguration;

  // if we got a result for the family configuration and if the new pause status is different from the current one, then continue
  if (areAllDefined(familyConfiguration) === false || isPaused === formatBoolean(familyConfiguration.isPaused)) {
    return;
  }

  // toggling everything to paused from unpaused
  if (isPaused) {
    await pause(databaseConnection, familyId, familyConfiguration.lastUnpause);
  }
  // toggling everything to unpaused from paused
  else {
    await unpause(databaseConnection, familyId);
  }

  // was successful in either pausing or unpausing
  createFamilyPausedNotification(userId, familyId, isPaused);
}

/**
 * Helper method for updateFamilyForFamilyId.
 * Saves all intervalElapsed, sets all reminderExecutionDates to nil, and deleteAlarmNotifications
 */
async function pause(databaseConnection, familyId, forLastUnpause) {
  const lastUnpause = formatDate(forLastUnpause);
  const lastPause = new Date();
  const dogLastModified = lastPause;
  const reminderLastModified = lastPause;

  // lastUnpause can be null if not paused before, not a deal breaker
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  await databaseQuery(
    databaseConnection,
    'UPDATE families SET isPaused = ?, lastPause = ? WHERE familyId = ?',
    [true, lastPause, familyId],
  );

  // retrieves reminders that match the familyId, have a non-null reminderExecutionDate, and either have isSnoozeEnabled = 1 or reminderType = 'countdown'
  // there are the reminders that will need their intervals elapsed saved before we pause, everything else doesn't need touched.
  const reminders = await databaseQuery(
    databaseConnection,
    'SELECT reminderId, reminderType, reminderExecutionBasis, snoozeIsEnabled, snoozeExecutionInterval, snoozeIntervalElapsed, countdownExecutionInterval, countdownIntervalElapsed FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId WHERE dogs.dogIsDeleted = 0 AND dogs.familyId = ? AND dogReminders.reminderIsDeleted = 0 AND dogReminders.reminderExecutionDate IS NOT NULL AND (snoozeIsEnabled = 1 OR reminderType = \'countdown\') LIMIT 18446744073709551615',
    [familyId],
  );

  // Update the intervalElapsed for countdown reminders and snoozed reminders
  const promises = [];
  for (let i = 0; i < reminders.length; i += 1) {
    const reminder = reminders[i];
    // update countdown timing
    if (reminder.reminderType === 'countdown') {
      let millisecondsElapsed;
      // the reminder has not has its interval elapsed changed before, meaning it's not been paused or unpaused since its current reminderExecutionBasis
      if (reminder.countdownIntervalElapsed === 0) {
        // the time greater in the future will have a greater number of milliseconds elapsed, so future - past = positive millisecond difference
        millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(reminder.reminderExecutionBasis).getTime());
      }
      // the reminder has had its interval elapsed changed, meaning it's been paused or unpaused since its current reminderExecutionBasis
      else {
        // since the reminder has been paused before, we must find the time elapsed since the last unpause to this pause
        millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(lastUnpause).getTime());
      }
      // reminderLastModified is modified below when we set all the executionDates to null
      promises.push(databaseQuery(
        databaseConnection,
        'UPDATE dogReminders SET countdownIntervalElapsed = ? WHERE reminderId = ?',
        [(millisecondsElapsed / 1000) + reminder.countdownIntervalElapsed, reminder.reminderId],
      ));
    }
    // update snooze timing
    else if (formatBoolean(reminder.isSnoozeEnabled)) {
      let millisecondsElapsed;
      // the reminder has not has its interval elapsed changed before, meaning it's not been paused or unpaused since its current reminderExecutionBasis
      if (reminder.snoozeIntervalElapsed === 0) {
        // the time greater in the future will have a greater number of milliseconds elapsed, so future - past = positive millisecond difference
        millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(reminder.reminderExecutionBasis).getTime());
      }
      // the reminder has had its interval elapsed changed, meaning it's been paused or unpaused since its current reminderExecutionBasis
      else {
        // since the reminder has been paused before, we must find the time elapsed since the last unpause to this pause
        millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(lastUnpause).getTime());
      }
      // reminderLastModified is modified below when all executionDates are set to null
      promises.push(databaseQuery(
        databaseConnection,
        'UPDATE dogReminders SET snoozeIntervalElapsed = ? WHERE reminderId = ?',
        [(millisecondsElapsed / 1000) + reminder.snoozeIntervalElapsed, reminder.reminderId],
      ));
    }
  }

  promises.push(
    // none of the reminders will be going off since their paused, meaning their executionDates will be null.
    // Update the reminderExecutionDates to NULL for all of the family's reminders
    // update both the dogLastModified and reminderLastModified
    databaseQuery(
      databaseConnection,
      'UPDATE dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId SET dogs.dogLastModified = ?, dogReminders.reminderExecutionDate = ?, dogReminders.reminderLastModified = ? WHERE dogs.familyId = ?',
      [dogLastModified, undefined, reminderLastModified, familyId],
    ),
  );

  await Promise.all(promises);

  // remove any alarm notifications that may be scheduled since everything is now paused and no need for alarms.
  deleteAlarmNotificationsForFamily(familyId);
}

/**
 * Helper method for updateFamilyForFamilyId.
 * Sets reminderExecutionBasis to Date(). The new reminderExecutionDates must be calculated by the user and sent to the server
 */
async function unpause(databaseConnection, familyId) {
  const lastUnpause = new Date();
  const dogLastModified = lastUnpause;
  const reminderLastModified = lastUnpause;

  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  // update the family's pause configuration to reflect changes
  await databaseQuery(
    databaseConnection,
    'UPDATE families SET isPaused = ?, lastUnpause = ? WHERE familyId = ?',
    [false, lastUnpause, familyId],
  );

  // once reminders are unpaused, they have an up to date intervalElapsed so need to base their timing off of the lastUnpause.
  // Update the reminderExecutionBasis to lastUnpause for all of the family's reminders
  await databaseQuery(
    databaseConnection,
    'UPDATE dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId SET dogs.dogLastModified = ?, dogReminders.reminderExecutionBasis = ?, dogReminders.reminderLastModified = ? WHERE dogs.familyId = ?',
    [dogLastModified, lastUnpause, reminderLastModified, familyId],
  );

  // currently no need to recreate/refresh alarm notifications. This is because the executionDates will all still be nil
  // User needs to update reminders with the executioDates calculated on their device

  // TO DO FUTURE have the server calculate the new reminderExecutionDates (if we do this, then have alarm notifications created for family)
}

module.exports = { updateFamilyForUserIdFamilyId };
