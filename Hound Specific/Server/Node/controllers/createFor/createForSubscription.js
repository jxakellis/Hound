const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { queryPromise } = require('../../main/tools/database/queryPromise');

/**
 *  Queries the database to create a ___. If the query is successful, then returns the ___.
 *  If a problem is encountered, creates and throws custom error
 */
const createSubscriptionForUserIdFamilyIdRecieptId = async (req, userId, familyId, encodedReceiptData) => {
  if (areAllDefined(userId, familyId, encodedReceiptData) === false) {
    throw new ValidationError('userId, familyId, or encodedReceiptData missing', 'ER_VALUES_MISSING');
  }
};

module.exports = { createSubscriptionForUserIdFamilyIdRecieptId };
