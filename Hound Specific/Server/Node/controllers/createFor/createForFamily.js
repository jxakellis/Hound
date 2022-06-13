const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { generateVerifiedFamilyCode } = require('../../main/tools/database/generateVerifiedFamilyCode');

const { getFamilyMembersForUserId } = require('../getFor/getForFamily');
const { areAllDefined } = require('../../main/tools/format/formatObject');
const { hash } = require('../../main/tools/format/hash');

/**
 *  Queries the database to create a family. If the query is successful, then returns the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const createFamilyQuery = async (req) => {
  const userId = req.params.userId; // required
  const familyAccountCreationDate = new Date();
  const familyId = await hash(userId, familyAccountCreationDate.toISOString());

  if (areAllDefined(userId, familyAccountCreationDate, familyId) === false) {
    throw new ValidationError('userId missing', 'ER_VALUES_MISSING');
  }

  // check if the user is already in a family
  const existingFamilyResult = await getFamilyMembersForUserId(req, userId);

  // validate that the user is not in a family
  if (existingFamilyResult.length !== 0) {
    throw new ValidationError('User is already in a family', 'ER_FAMILY_ALREADY');
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

module.exports = { createFamilyQuery };
