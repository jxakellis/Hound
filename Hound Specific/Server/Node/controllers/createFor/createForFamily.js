const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { generateVerifiedFamilyCode } = require('../../main/tools/database/generateVerifiedFamilyCode');

const { getFamilyMembersForUserIdQuery } = require('../getFor/getForFamily');

/**
 *  Queries the database to create a family. If the query is successful, then returns the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const createFamilyQuery = async (req) => {
  const userId = req.params.userId;

  try {
    // check if the user is already in a family
    const existingFamilyResult = await getFamilyMembersForUserIdQuery(req, userId);
    if (existingFamilyResult.length !== 0) {
      throw new ValidationError('User is already in a family', 'ER_ALREADY_PRESENT');
    }
    const familyCode = await generateVerifiedFamilyCode(req);
    const result = await queryPromise(
      req,
      'INSERT INTO families(userId, familyCode) VALUES (?, ?)',
      [userId, familyCode],
    );
    const familyId = result.insertId;
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
