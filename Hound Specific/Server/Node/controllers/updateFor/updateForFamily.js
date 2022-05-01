const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatBoolean, formatDate, areAllDefined,
} = require('../../utils/database/validateFormat');

const { deleteAlarmNotificationsForFamily } = require('../../utils/notification/alarm/deleteAlarmNotification');
/**
 *  Queries the database to update a family to add a new user. If the query is successful, then returns
 *  If a problem is encountered, creates and throws custom error
 */
// eslint-disable-next-line consistent-return
const updateFamilyQuery = async (req) => {
  const familyId = req.params.familyId;

  // familyId doesn't exist, so user must want to join a family
  if (areAllDefined(familyId) === false) {
    return addFamilyMemberQuery(req);
  }
  // familyId exists, so we update values the traditional way
  else {
    const isLocked = formatBoolean(req.body.isLocked);
    const isPaused = formatBoolean(req.body.isPaused);

    try {
      if (areAllDefined(isLocked)) {
        await queryPromise(
          req,
          'UPDATE families SET isLocked = ? WHERE familyId = ?',
          [isLocked, familyId],
        );
      }
      else if (areAllDefined(isPaused)) {
        await updateIsPausedQuery(req);
      }
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
};

// columns for SELECT statement for updateIsPausedQuery
const reminderSnoozeComponentsSelect = 'reminderSnoozeComponents.snoozeIsEnabled, reminderSnoozeComponents.snoozeExecutionInterval, reminderSnoozeComponents.snoozeIntervalElapsed';
const reminderCountdownComponentsSelect = 'reminderCountdownComponents.countdownExecutionInterval, reminderCountdownComponents.countdownIntervalElapsed';

const reminderSnoozeComponentsLeftJoin = 'LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId';
const reminderCountdownComponentsLeftJoin = 'LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId';

const updateIsPausedQuery = async (req) => {
  const familyId = req.params.familyId;
  const isPaused = formatBoolean(req.body.isPaused);

  try {
    // find out the family's current pause status
    const familyConfiguration = await queryPromise(
      req,
      'SELECT isPaused, lastPause, lastUnpause FROM families WHERE familyId = ? LIMIT 1',
      [familyId],
    );

    // if we got a result for the family configuration and if the new pause status is different from the current one, then continue
    if (familyConfiguration.length === 1 && isPaused !== formatBoolean(familyConfiguration[0].isPaused)) {
      // toggling everything to paused from unpaused
      if (isPaused === true) {
        // update the family's pause configuration to reflect changes
        const lastPause = new Date();
        await queryPromise(
          req,
          'UPDATE families SET isPaused = ?, lastPause = ? WHERE familyId = ?',
          [true, lastPause, familyId],
        );

        // retrieves reminders that match the familyId, have a non-null reminderExecutionDate, and either have isSnoozeEnabled = 1 or reminderType = 'countdown'
        // there are the reminders that will need their intervals elapsed saved before we pause, everything else doesn't need touched.
        const reminders = await queryPromise(
          req,
          `SELECT dogReminders.reminderId, dogReminders.reminderType, dogReminders.reminderExecutionBasis, ${reminderSnoozeComponentsSelect}, ${reminderCountdownComponentsSelect} FROM dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId ${reminderSnoozeComponentsLeftJoin} ${reminderCountdownComponentsLeftJoin} WHERE dogs.familyId = ? AND dogReminders.reminderExecutionDate IS NOT NULL AND (reminderSnoozeComponents.snoozeIsEnabled = 1 OR dogReminders.reminderType = 'countdown') LIMIT 18446744073709551615`,
          [familyId],
        );

        // Update the intervalElapsed for countdown reminders and snoozed reminders
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
              millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(familyConfiguration[0].lastUnpause).getTime());
            }
            await queryPromise(
              req,
              'UPDATE reminderCountdownComponents SET countdownIntervalElapsed = ? WHERE reminderId = ?',
              [(millisecondsElapsed / 1000) + reminder.countdownIntervalElapsed, reminder.reminderId],
            );
          }
          // update snooze timing
          else if (formatBoolean(reminder.isSnoozeEnabled) === true) {
            let millisecondsElapsed;
            // the reminder has not has its interval elapsed changed before, meaning it's not been paused or unpaused since its current reminderExecutionBasis
            if (reminder.snoozeIntervalElapsed === 0) {
            // the time greater in the future will have a greater number of milliseconds elapsed, so future - past = positive millisecond difference
              millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(reminder.reminderExecutionBasis).getTime());
            }
            // the reminder has had its interval elapsed changed, meaning it's been paused or unpaused since its current reminderExecutionBasis
            else {
            // since the reminder has been paused before, we must find the time elapsed since the last unpause to this pause
              millisecondsElapsed = Math.abs(lastPause.getTime() - formatDate(familyConfiguration[0].lastUnpause).getTime());
            }
            await queryPromise(
              req,
              'UPDATE reminderSnoozeComponents SET snoozeIntervalElapsed = ? WHERE reminderId = ?',
              [(millisecondsElapsed / 1000) + reminder.snoozeIntervalElapsed, reminder.reminderId],
            );
          }
        }

        // none of the reminders will be going off since their paused, meaning their executionDates will be null.
        // Update the reminderExecutionDates to NULL for all of the family's reminders
        await queryPromise(
          req,
          'UPDATE dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId SET dogReminders.reminderExecutionDate = NULL WHERE dogs.familyId = ?',
          [familyId],
        );

        // remove any alarm notifications that may be scheduled since everything is now paused and no need for alarms.
        deleteAlarmNotificationsForFamily(familyId);
      }
      // toggling everything to unpaused from paused
      else {
        const lastUnpause = new Date();
        // update the family's pause configuration to reflect changes
        await queryPromise(
          req,
          'UPDATE families SET isPaused = ?, lastUnpause = ? WHERE familyId = ?',
          [false, lastUnpause, familyId],
        );

        // once reminders are unpaused, they have an up to date intervalElapsed so need to base their timing off of the lastUnpause.
        // Update the reminderExecutionBasis to lastUnpause for all of the family's reminders
        await queryPromise(
          req,
          'UPDATE dogReminders JOIN dogs ON dogReminders.dogId = dogs.dogId SET dogReminders.reminderExecutionBasis = ? WHERE dogs.familyId = ?',
          [lastUnpause, familyId],
        );
      }
    }
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 * Helper method for updateFamilyQuery, goes through checks to attempt to add user to desired family
 */
const addFamilyMemberQuery = async (req) => {
  let familyCode = req.body.familyCode;
  // make sure familyCode was provided
  if (areAllDefined(familyCode) === false) {
    throw new ValidationError('familyCode missing', 'ER_VALUES_MISSING');
  }
  familyCode = familyCode.toUpperCase();

  let result;
  try {
    // retrieve information about the family linked to the familyCode
    result = await queryPromise(
      req,
      'SELECT familyId, isLocked FROM families WHERE familyCode = ?',
      [familyCode],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // make sure the familyCode was valid by checking if it matched a family
  if (result.length === 0) {
    // result length is zero so there are no families with that familyCode
    throw new ValidationError('familyCode invalid, not found', 'ER_NOT_FOUND');
  }
  result = result[0];
  const isLocked = formatBoolean(result.isLocked);
  // familyCode exists and is linked to a family, now check if family is locked against new members
  if (isLocked === true) {
    throw new ValidationError('Family is locked', 'ER_FAMILY_LOCKED');
  }

  // the familyCode is valid and linked to an UNLOCKED family
  const userId = req.params.userId;
  try {
    // insert the user into the family as a family member.
    await queryPromise(
      req,
      'INSERT INTO familyMembers(familyId, userId) VALUES (?, ?)',
      [result.familyId, userId],
    );
    return;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { updateFamilyQuery };
