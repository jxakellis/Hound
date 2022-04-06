const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');
const { formatNumber } = require('../../utils/validateFormat');
const { generateVerifiedFamilyCode } = require('../../utils/familyCode');

const { getFamilyMembersForUserIdQuery } = require('../getFor/getForFamily');

/**
 *  Queries the database to create a family. If the query is successful, then returns the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const createFamilyQuery = async (req) => {
  const userId = formatNumber(req.params.userId);

  try {
    // check if the user is already in a family
    const existingFamilyResult = await getFamilyMembersForUserIdQuery(req, userId);
    if (existingFamilyResult.length !== 0) {
      throw new ValidationError('User is already in a family', 'ER_ALREADY_PRESENT');
    }
    const familyCode = await generateVerifiedFamilyCode(req);
    const result = await queryPromise(
      req,
      'INSERT INTO familyHeads(userId, familyCode, familyIsLocked) VALUES (?, ?, ?)',
      [userId, familyCode, false],
    );
    const familyId = formatNumber(result.insertId);
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
