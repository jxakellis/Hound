const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined, atLeastOneDefined } = require('../../main/tools/format/validateDefined');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatBoolean,
} = require('../../main/tools/format/formatObject');
const { getFamilyHeadUserIdForFamilyId } = require('../getFor/getForFamily');
const { getInAppSubscriptionForTransactionId } = require('../getFor/getForInAppSubscriptions');

async function updateInAppSubscriptionForUserIdFamilyIdTransactionInfo(databaseConnection, transactionId, userId, familyId, autoRenewStatus, revocationReason) {
  console.log('updateInAppSubscriptionForUserIdFamilyIdTransactionInfo');
  if (areAllDefined(databaseConnection, transactionId, userId, familyId) === false) {
    throw new ValidationError('databaseConnection, transactionId, userId, or familyId missing', global.constant.error.value.MISSING);
  }

  let isAutoRenewing = formatBoolean(autoRenewStatus);
  console.log('provided renewing');
  console.log(isAutoRenewing);
  console.log(autoRenewStatus);
  // If revocation reason is defined, then that means the transaction was revoked for a given reason (which we don't care about)
  let isRevoked = areAllDefined(revocationReason);
  console.log('provided revoked');
  console.log(isRevoked);
  console.log(revocationReason);

  if (atLeastOneDefined(isAutoRenewing, isRevoked) === false) {
    throw new ValidationError('isAutoRenewing or isRevoked missing', global.constant.error.value.MISSING);
  }

  const familyHeadUserId = await getFamilyHeadUserIdForFamilyId(databaseConnection, familyId);

  if (familyHeadUserId !== userId) {
    throw new ValidationError('You are not the family head. Only the family head can modify the family subscription', global.constant.error.family.permission.INVALID);
  }

  const transaction = await getInAppSubscriptionForTransactionId(databaseConnection, transactionId);

  if (areAllDefined(transaction) === false) {
    throw new ValidationError('transaction missing', global.constant.error.value.MISSING);
  }

  // Let the new values take precident over the stored values, but if no new value then use the pre-existing value
  isAutoRenewing = areAllDefined(isAutoRenewing) ? isAutoRenewing : transaction.isAutoRenewing;
  isRevoked = areAllDefined(isRevoked) ? isRevoked : transaction.isRevoked;

  console.log('precident');
  console.log(isAutoRenewing);
  console.log(isRevoked);

  /*
  Once a transaction is performed, certain values shouldn't be changed
  IMMUTABLE transactionId
  IMMUTABLE originalTransactionId
  IMMUTABLE userId
  IMMUTABLE familyId
  IMMUTABLE productId
  IMMUTABLE subscriptionGroupIdentifier
  IMMUTABLE purchaseDate
  IMMUTABLE expirationDate
  IMMUTABLE numberOfFamilyMembers
  IMMUTABLE numberOfDogs
  IMMUTABLE quantity
  IMMUTABLE webOrderLineItemId
  IMMUTABLE inAppOwnershipType
  MUTABLE isAutoRenewing
  MUTABLE isRevoked
  */

  await databaseQuery(
    databaseConnection,
    'UPDATE transactions SET isAutoRenewing = ?, isRevoked = ? WHERE transactionId = ?',
    [isAutoRenewing, isRevoked, transactionId],
  );
}

module.exports = { updateInAppSubscriptionForUserIdFamilyIdTransactionInfo };
