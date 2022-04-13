const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const { deleteDogsQuery } = require('./deleteForDogs');

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

  // User is not the head of their family and has no responsibility. Can leave family and delete user
  if (familyHeads.length === 0) {
    try {
      // deletes user from family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE userId = ?', [userId]);

      // perform rest of deletion

      // delete userConfiguration
      await queryPromise(req, 'DELETE FROM userConfiguration WHERE userId = ?', [userId]);
      // deletes user
      await queryPromise(req, 'DELETE FROM users WHERE userId = ?', [userId]);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
  }
  // User is the head of their family and is the ONLY family member. Therefore no responsibility so can delete family and delete user
  else if (familyMembers.length === 1) {
    try {
      // delete the family head which is the user
      await queryPromise(req, 'DELETE FROM familyHeads WHERE userId = ?', [userId]);

      // perform rest of deletion

      // deletes user from family
      await queryPromise(req, 'DELETE FROM familyMembers WHERE userId = ?', [userId]);
      // delete userConfiguration
      await queryPromise(req, 'DELETE FROM userConfiguration WHERE userId = ?', [userId]);
      // deletes user
      await queryPromise(req, 'DELETE FROM users WHERE userId = ?', [userId]);
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }

    // delete all the dogs
    await deleteDogsQuery(req, familyId);
  }
  else {
    throw new ValidationError("User's family still has other members in it", 'ER_VALUES_INVALID');
  }
};

module.exports = { deleteUserQuery };
