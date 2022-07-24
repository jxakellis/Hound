const { serverLogger } = require('./loggers');
const { databaseQuery } = require('../database/databaseQuery');
const { connectionForLogging } = require('../database/databaseConnections');
const { formatString } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');

// Outputs response to the console and logs to database
function logServerError(forFunction, forError) {
  const errorDate = new Date();

  let errorFunction = formatString(forFunction);
  errorFunction = areAllDefined(errorFunction) ? errorFunction.substring(0, 100) : errorFunction;

  let errorName = formatString(forError && forError.constructor && forError.constructor.name);
  errorName = areAllDefined(errorName) ? errorName.substring(0, 500) : errorName;

  let errorMessage = formatString(forError && forError.message);
  errorMessage = areAllDefined(errorMessage) ? errorMessage.substring(0, 500) : errorMessage;

  let errorCode = formatString(forError && forError.code);
  errorCode = areAllDefined(errorCode) ? errorCode.substring(0, 500) : errorCode;

  let errorStack = formatString(forError && forError.stack);
  errorStack = areAllDefined(errorStack) ? errorStack.substring(0, 2500) : errorStack;

  if (global.constant.server.SHOW_CONSOLE_MESSAGES) {
    serverLogger.error(`Function ${errorFunction} generated an uncaught ${errorName}: ${errorMessage} ${errorCode} ${errorStack}`);
  }

  databaseQuery(
    connectionForLogging,
    'INSERT INTO previousErrors(errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack) VALUES (?,?,?,?,?,?)',
    [errorDate, errorFunction, errorName, errorMessage, errorCode, errorStack],
  ).catch(
    (databaseError) => {
      // Failed to log error
      serverLogger.error(`Function logServerError generated an uncaught error: ${databaseError}`);
    },
  );
}

module.exports = { logServerError };
