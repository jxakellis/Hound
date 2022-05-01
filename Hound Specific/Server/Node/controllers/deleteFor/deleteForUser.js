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
  let family;
  try {
    // find the amount of family members in the family
    familyMembers = await queryPromise(
      req,
      'SELECT userId FROM familyMembers WHERE familyId = ? LIMIT 18446744073709551615',
      [familyId],
    );
    // find out if the user is the family head
    family = await queryPromise(
      req,
      'SELECT userId FROM families WHERE familyId = ? AND userId = ? LIMIT 18446744073709551615',
      [familyId, userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // Either:
  // 1. user not head of family, so they can leave family and we can delete the user
  // 2. user is head of family but only familyMember, so we can delete the family and delete the user
  if (family.length === 0 || (family.length === 1 && familyMembers.length === 1)) {
    try {
      if (family.length === 1 && familyMembers.length === 1) {
        // User is the ONLY family member and the head of the family. We will delete the family

        // delete the family head which is the user
        await queryPromise(req, 'DELETE FROM families WHERE familyId = ?', [familyId]);
        // delete all the dogs in the family since deleting the family
        await deleteDogsQuery(req, userId, familyId);
      }
      // No matter what, we delete the user and their information
      // deletes user from family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE familyId = ?', [familyId]);
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
