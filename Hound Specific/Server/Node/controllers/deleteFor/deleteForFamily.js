const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { deleteAllDogsForFamilyId } = require('./deleteForDogs');
const { createFamilyMemberLeaveNotification } = require('../../main/tools/notifications/alert/createFamilyNotification');

/**
 *  Queries the database to either remove the user from their current family (familyMember) or delete the family and everything nested under it (families).
 *  If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteFamilyQuery = async (req, userId, familyId) => {
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

  // User is the head of the family, so has obligation to it.
  if (family.length === 1) {
    if (familyMembers.length !== 1) {
      // Cannot destroy family until other members are gone
      throw new ValidationError('Family still contains multiple members', 'ER_VALUES_INVALID');
    }

    // can destroy the family
    try {
    // delete all the family heads (should be one)
      await queryPromise(req, 'DELETE FROM families WHERE familyId = ?', [familyId]);
      // deletes all users from the family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE familyId = ?', [familyId]);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }

    // delete all the dogs
    await deleteAllDogsForFamilyId(req, familyId);
  }
  // User is not the head of the family, so no obligation
  else {
  // can leave the family
    try {
    // deletes user from family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE userId = ?', [userId]);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }

  // now that the user has successfully left their family (or destroyed it), we can send a notification to remaining members
  // NOTE: in the case of the user being the family head (aka the only family members if we reached this point),
  // this will ultimately find no userNotificationTokens for the other family members and send no APN
  createFamilyMemberLeaveNotification(userId, familyId);
};

module.exports = { deleteFamilyQuery };
