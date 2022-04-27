const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/database/queryPromise');
const {
  formatBoolean, formatDate, areAllDefined,
} = require('../../utils/database/validateFormat');

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
    const lastPause = formatDate(req.body.lastPause);
    const lastUnpause = formatDate(req.body.lastUnpause);

    try {
      if (areAllDefined(isLocked)) {
        await queryPromise(
          req,
          'UPDATE families SET isLocked = ? WHERE familyId = ?',
          [isLocked, familyId],
        );
      }
      if (areAllDefined(isPaused)) {
        await queryPromise(
          req,
          'UPDATE families SET isPaused = ? WHERE familyId = ?',
          [isPaused, familyId],
        );
      }
      if (areAllDefined(lastPause)) {
        await queryPromise(
          req,
          'UPDATE families SET lastPause = ? WHERE familyId = ?',
          [lastPause, familyId],
        );
      }
      if (areAllDefined(lastUnpause)) {
        await queryPromise(
          req,
          'UPDATE families SET lastUnpause = ? WHERE familyId = ?',
          [lastUnpause, familyId],
        );
      }
    }
    catch (error) {
      throw new DatabaseError(error.code);
    }
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
