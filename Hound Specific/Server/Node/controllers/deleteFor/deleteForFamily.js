const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const { deleteDogsQuery } = require('./deleteForDogs');

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
      'SELECT userId FROM familyMembers WHERE familyId = ?',
      [familyId],
    );
    // find out if the user is the family head
    family = await queryPromise(
      req,
      'SELECT userId FROM families WHERE familyId = ? AND userId = ?',
      [familyId, userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // User is the head of the family, so has obligation to it.
  if (family.length === 1) {
  // The user is the only person in the family.
    if (familyMembers.length === 1) {
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
      await deleteDogsQuery(req, userId, familyId);
    }
    // There are multiple people in the family
    else {
      // Cannot destroy family until other members are gone
      throw new ValidationError('Family still contains multiple members', 'ER_VALUES_INVALID');
    }
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
};

module.exports = { deleteFamilyQuery };
