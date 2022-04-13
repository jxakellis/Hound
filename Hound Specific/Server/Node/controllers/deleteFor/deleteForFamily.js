const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/database/queryPromise');
const { deleteDogsQuery } = require('./deleteForDogs');

/**
 *  Queries the database to delete a family and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteFamilyQuery = async (req, userId, familyId) => {
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

  // User is not the head of the family so invalid permissions.
  if (familyHeads.length !== 1) {
    throw new ValidationError('No family found or invalid permissions', 'ER_NOT_FOUND');
  }
  // Family has multiple members inside of it so need to remove them first
  else if (familyMembers.length !== 1) {
    throw new ValidationError('Family still contains multiple members', 'ER_VALUES_INVALID');
  }

  // User is the head of their family and there are no other members in the family. Can delete the family now
  try {
    // delete the family head which is the user
    await queryPromise(req, 'DELETE FROM familyHeads WHERE familyId = ?', [familyId]);
    // deletes user from family
    await queryPromise(req, 'DELETE FROM familyMembers WHERE familyId = ?', [familyId]);
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // delete all the dogs
  await deleteDogsQuery(req, familyId);
};

module.exports = { deleteFamilyQuery };
