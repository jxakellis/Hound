const { serverLogger } = require('./loggers');
const { databaseConnectionForLogging } = require('../database/establishDatabaseConnections');
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

  serverLogger.error(`UNCAUGHT '${errorName}' FROM FUNCTION: ${errorFunction}\n MESSAGE: ${errorMessage}\n CODE: ${errorCode}\n STACK: ${errorStack}`);

  await databaseQuery(
    databaseConnectionForLogging,
    'INSERT INTO previousServerErrors(errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack) VALUES (?,?,?,?,?,?)',
    [errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack],
  ).catch((databaseError) => serverLogger.error(`UNCAUGHT '${databaseError.name}' FROM FUNCTION: logServerError\n MESSAGE: ${databaseError.message}\n CODE: ${databaseError.code}\n STACK: ${databaseError.stack}`));
}

module.exports = { logServerError };
