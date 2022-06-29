const axios = require('axios').default;
const { requestLogger } = require('../logging/loggers');
const { houndSharedSecret } = require('../../secrets/houndSharedSecret');

const verifyReceipt = async (encodedReceiptData) => {
  requestLogger.info(`verifyReceipt ${encodedReceiptData}`);

  const requestBody = {
    // (Required) The Base64-encoded receipt data.
    'receipt-data': encodedReceiptData,
    // password (string): Your app’s shared secret, which is a hexadecimal string. For more information about the shared secret, see Generate a Receipt Validation Code.
    password: houndSharedSecret,
    // Set this value to true for the response to include only the latest renewal transaction for any subscriptions. Use this field only for app receipts that contain auto-renewable subscriptions.
    'exclude-old-transactions': false,
  };

  try {
    const productionResult = await axios.post('https://buy.itunes.apple.com/verifyReceipt', requestBody);
    // const sandboxResult = await axios.post('https://buy.itunes.apple.com/verifyReceipt', requestBody);
    console.log(productionResult);
  }
  catch (error) {
    console.log(error);
  }

  /*
        Submit this JSON object as the payload of an HTTP POST request.
        Use the test environment URL https://sandbox.itunes.apple.com/verifyReceipt when testing your app in the sandbox and while your application is in review.
        Use the production URL https://buy.itunes.apple.com/verifyReceipt when your app is live in the App Store.
        For more information on these endpoints, see verifyReceipt.
      */
};
