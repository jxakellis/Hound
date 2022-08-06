const { serverLogger } = require('./loggers');
const { serverConnectionForLogging } = require('../database/databaseConnections');
const { databaseQuery } = require('../database/databaseQuery');
const { formatString } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');

// Outputs response to the console and logs to database
async function logServerError(forFunction, forError) {
  const errorDate = new Date();

  let errorFunction = formatString(forFunction);
  errorFunction = areAllDefined(errorFunction) ? errorFunction.substring(0, 100) : errorFunction;

  let errorName = formatString(forError && forError.constructor && forError.constructor.name);
  errorName = areAllDefined(errorName) ? errorName.substring(0, 500) : errorName;

  let errorMessage = formatString(forError && forError.message);
  errorMessage = areAllDefined(errorMessage) ? errorMessage.substring(0, 500) : errorMessage;

  let errorCode = formatString(forError && forError.code);
  errorCode = areAllDefined(errorCode) ? errorCode.substring(0, 500) : errorCode;

  // Attempt to get the .stack. If the stack is undefined, then we just simply get the error
  let errorStack = formatString((forError && forError.stack) || forError);
  errorStack = areAllDefined(errorStack) ? errorStack.substring(0, 2500) : errorStack;

  serverLogger.error(`Function ${errorFunction} generated an uncaught ${errorName}: ${errorMessage} ${errorCode} ${errorStack}`);

  try {
    await databaseQuery(
      serverConnectionForLogging,
      'INSERT INTO previousServerErrors(errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack) VALUES (?,?,?,?,?,?)',
      [errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack],
    );
  }
  catch (databaseError) {
    // Failed to log error
    serverLogger.error(`Function logServerError generated an uncaught error: ${databaseError}`);
  }
}

module.exports = { logServerError };
