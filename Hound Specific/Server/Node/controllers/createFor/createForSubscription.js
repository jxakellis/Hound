const axios = require('axios').default;
const { GeneralError } = require('../../main/tools/errors/generalError');
const { DatabaseError } = require('../../main/tools/errors/databaseError');
const { ValidationError } = require('../../main/tools/errors/validationError');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const { houndSharedSecret } = require('../../main/secrets/houndSharedSecret');
const { formatBase64EncodedString, formatArray, formatNumber } = require('../../main/tools/format/formatObject');
const { getActiveSubscriptionForFamilyId } = require('../getFor/getForSubscription');
const { getFamilyHeadForFamilyId } = require('../getFor/getForFamily');

/**
 *  Queries the database to create a ___. If the query is successful, then returns the ___.
 *  If a problem is encountered, creates and throws custom error
 */
const createSubscriptionForUserIdFamilyIdRecieptId = async (req, userId, familyId, recieptData) => {
  // Takes a base64 encoded appStoreReceiptURL from a user
  const base64EncodedReceiptData = formatBase64EncodedString(recieptData);

  if (areAllDefined(req, userId, familyId, base64EncodedReceiptData) === false) {
    throw new ValidationError('req, userId, familyId, or base64EncodedReceiptData missing', global.constant.error.value.MISSING);
  }

  const familyHeadUserId = await getFamilyHeadForFamilyId(req, familyId);

  if (familyHeadUserId !== userId) {
    throw new ValidationError('You are not the family head. Only the family head can modify the family subscription', global.constant.error.family.permission.INVALID);
  }

  const requestBody = {
    // (Required) The Base64-encoded receipt data.
    'receipt-data': base64EncodedReceiptData,
    // password (string): Your app’s shared secret, which is a hexadecimal string. For more information about the shared secret, see Generate a Receipt Validation Code.
    password: houndSharedSecret,
    // Set this value to true for the response to include only the latest renewal transaction for any subscriptions. Use this field only for app receipts that contain auto-renewable subscriptions.
    'exclude-old-transactions': false,
  };

  let result;
  try {
    // query Apple's iTunes server to verify that the receipt is valid
    result = await axios.post('https://buy.itunes.apple.com/verifyReceipt', requestBody);
    // 21007 status indicates that the receipt is from the sandbox environment, so we retry with the sandbox url
    if (result.data.status === 21007) {
      result = await axios.post('https://sandbox.itunes.apple.com/verifyReceipt', requestBody);
    }
  }
  catch (error) {
    throw new GeneralError("There was an error querying Apple's iTunes server to verify the receipt", global.constant.error.general.APPLE_SERVER_FAILED);
  }

  // verify that the status is successful
  if (formatNumber(result.data.status) !== 0) {
    throw new GeneralError("There was an error querying Apple's iTunes server to verify the receipt", global.constant.error.general.APPLE_SERVER_FAILED);
  }

  // check to see the result has a body
  const resultBody = result.data;
  if (areAllDefined(resultBody) === false) {
    throw new ValidationError("Unable to parse the responseBody from Apple's iTunes servers", global.constant.error.value.MISSING);
  }

  // check to see .latest_receipt_info array exists
  const resultLatestReceiptInfo = formatArray(resultBody.latest_receipt_info);
  if (areAllDefined(resultLatestReceiptInfo) === false) {
    throw new ValidationError("Unable to parse the responseBody from Apple's iTunes servers", global.constant.error.value.MISSING);
  }

  // update the records stored for all receipts returned
  await updateReceiptRecords(req, resultLatestReceiptInfo);

  // get the most recent subscription to return to the user
  return getActiveSubscriptionForFamilyId(req, familyId);
};

/**
 * Takes array of latest_receipt_info from the Apple /processReceipt API endpoint
 * Filters the receipts against productIds that are known
 * Compare receipts to stored transactions, inserting receipts into the database that aren't stored
 */
const updateReceiptRecords = async (req, latestReceiptInfo) => {
  const userId = req.params.userId;
  const familyId = req.params.familyId;
  const receipts = formatArray(latestReceiptInfo);
  const subscriptionLastModified = new Date();

  if (areAllDefined(req, userId, familyId, receipts) === false) {
    throw new ValidationError('req, userId, familyId, or latestReceiptInfo missing', global.constant.error.value.MISSING);
  }

  // Filter the receipts. Only include one which their productIds are known, and assign values if receipt is valid
  for (let i = 0; i < receipts.length; i += 1) {
    const receipt = receipts[i];
    const correspondingSubscription = global.constant.subscription.SUBSCRIPTIONS.find((subscription) => subscription.productId === receipt.product_id);

    // check to see if we found an item
    if (areAllDefined(correspondingSubscription) === false) {
      // a correspondingSubscription doesn't exist, remove the receipt from the array as incompatible
      receipts.splice(i, 1);
      // de iterate i so we don't skip an item
      i -= 1;
    }

    // we found a corresponding subscription, assign the correst values to the receipt
    receipt.subscriptionNumberOfFamilyMembers = correspondingSubscription.subscriptionNumberOfFamilyMembers;
    receipt.subscriptionNumberOfDogs = correspondingSubscription.subscriptionNumberOfDogs;
  }

  // find all of our currently stored transactions for the user
  // Specifically don't filter by familyId, as we want to reflect all of the stored transactions for a user (regardless of what family they were in at the time)

  let storedTransactions;
  try {
    storedTransactions = await queryPromise(
      req,
      'SELECT transactionId FROM subscriptions WHERE userId = ? LIMIT 18446744073709551615',
      [userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  // iterate through all the receipts that exist
  for (let i = 0; i < receipts.length; i += 1) {
    const receipt = receipts[i];
    const transactionId = formatNumber(receipt.transaction_id);

    // check to see if we have that receipt stored in the database
    if (storedTransactions.some((storedTransaction) => formatNumber(storedTransaction.transactionId) === transactionId) === false) {
      // we don't have that receipt stored, insert it into the database
      try {
        await queryPromise(
          req,
          'INSERT INTO subscriptions(transactionId, productId, familyId, userId, subscriptionPurchaseDate, subscriptionLastModified, subscriptionExpiration, subscriptionNumberOfFamilyMembers, subscriptionNumberOfDogs) VALUES (?,?,?,?,?,?,?,?,?)',
          [transactionId, receipt.product_id, familyId, userId, new Date(formatNumber(receipt.purchase_date_ms)), subscriptionLastModified, new Date(formatNumber(receipt.expires_date_ms)), receipt.subscriptionNumberOfDogs, receipt.subscriptionNumberOfFamilyMembers],
        );
      }
      catch (error) {
        throw new DatabaseError(error.code);
      }
    }
  }

  // now all of the receipts returned by apple (who's productId's match one that is known to us) are stored in our database
};

module.exports = { createSubscriptionForUserIdFamilyIdRecieptId };
