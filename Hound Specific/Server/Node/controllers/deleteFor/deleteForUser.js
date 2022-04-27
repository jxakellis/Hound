const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const { deleteDogsQuery } = require('./deleteForDogs');
const { deleteSecondaryAlarmNotificationsForUser } = require('../../utils/notification/alarm/deleteAlarmNotification');

/**
 *  Queries the database to delete a user and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteUserQuery = async (req, userId, familyId) => {
  let familyMembers;
  let familyHeads;
  try {
    // find the amount of family members in the family
    familyMembers = await queryPromise(
      req,
      'SELECT userId FROM familyMembers WHERE familyId = ?',
      [familyId],
    );
    // find out if the user is the family head
    familyHeads = await queryPromise(
      req,
      'SELECT userId FROM familyHeads WHERE familyId = ? AND userId = ?',
      [familyId, userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // Either:
  // 1. user not familyHead, so they can leave family and we can delete the user
  // 2. user is familyHead but only familyMember, so we can delete the family and delete the user
  if (familyHeads.length === 0 || (familyHeads.length === 1 && familyMembers.length === 1)) {
    try {
      if (familyHeads.length === 1 && familyMembers.length === 1) {
        // User is the ONLY family member and the familyHead. We will delete the family

        // delete the family head which is the user
        await queryPromise(req, 'DELETE FROM familyHeads WHERE userId = ?', [userId]);
        // delete all the dogs in the family since deleting the family
        await deleteDogsQuery(req, userId, familyId);
      }
      // No matter what, we delete the user and their information
      // deletes user from family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE userId = ?', [userId]);
      // delete userConfiguration
      await queryPromise(req, 'DELETE FROM userConfiguration WHERE userId = ?', [userId]);
      // deletes user
      await queryPromise(req, 'DELETE FROM users WHERE userId = ?', [userId]);
      // delete their secondary notifications
      // technically not required to do as their notification token will be deleted (so no APN will be sent), but this reduces the load on our schedules
      deleteSecondaryAlarmNotificationsForUser(userId);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
  else {
    throw new ValidationError("User's family still has other members in it", 'ER_VALUES_INVALID');
  }
};

module.exports = { deleteUserQuery };
