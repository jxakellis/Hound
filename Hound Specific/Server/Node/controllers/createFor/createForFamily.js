const { DatabaseError } = require('../../main/tools/errors/databaseError');
const { ValidationError } = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { hash } = require('../../main/tools/format/hash');

const { generateVerifiedFamilyCode } = require('../../main/tools/database/generateVerifiedFamilyCode');
const { getFamilyMemberForUserId } = require('../getFor/getForFamily');

/**
 *  Queries the database to create a family. If the query is successful, then returns the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const createFamilyForUserId = async (req, userId) => {
  if (areAllDefined(req, userId) === false) {
    throw new ValidationError('req or userId missing', global.constant.error.value.MISSING);
  }

  const familyAccountCreationDate = new Date();
  const familyId = await hash(userId, familyAccountCreationDate.toISOString());

  if (areAllDefined(userId, familyAccountCreationDate, familyId) === false) {
    throw new ValidationError('userId, familyAccountCreationDate, or familyId missing', global.constant.error.value.MISSING);
  }

  // check if the user is already in a family
  const existingFamilyResult = await getFamilyMemberForUserId(req, userId);

  // validate that the user is not in a family
  if (existingFamilyResult.length !== 0) {
    throw new ValidationError('User is already in a family', global.constant.error.family.join.IN_FAMILY_ALREADY);
  }

  try {
    // create a family code for the new family
    const familyCode = await generateVerifiedFamilyCode(req);
    await queryPromise(
      req,
      'INSERT INTO families(familyId, userId, familyCode, isLocked, isPaused, familyAccountCreationDate) VALUES (?, ?, ?, ?, ?, ?)',
      [familyId, userId, familyCode, false, false, familyAccountCreationDate],
    );
    await queryPromise(
      req,
      'INSERT INTO familyMembers(familyId, userId) VALUES (?, ?)',
      [familyId, userId],
    );

    return familyId;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { createFamilyForUserId };
