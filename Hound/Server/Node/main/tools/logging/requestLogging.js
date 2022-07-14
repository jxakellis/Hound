const { requestLogger, serverLogger } = require('./loggers');
const { databaseQuery } = require('../database/databaseQuery');
const { connectionForLogging } = require('../database/databaseConnections');
const { areAllDefined } = require('../format/validateDefined');
const { formatBoolean } = require('../format/formatObject');

// Uses requestLogger to output the request from a user in the console
function requestLoggerForRequest(req, res, next) {
  if (global.constant.server.IS_PRODUCTION === false) {
    requestLogger.info(`Request for ${req.method} ${req.originalUrl}`);
  }

  next();
}

// Inserts request information into the previousRequests table. This should only be called after the user is verified.
function createLogForRequest(req, res, next) {
  const requestIP = req.ip; // can be undefined
  const requestDate = new Date();
  const requestMethod = req.method;
  const requestOriginalURL = req.originalUrl;
  const { appBuild, userId } = req.params;

  const hasBeenLogged = formatBoolean(req.hasBeenLogged);

  if (areAllDefined(requestDate, requestMethod, requestOriginalURL, appBuild) && hasBeenLogged === false) {
    req.hasBeenLogged = true;
    databaseQuery(
      connectionForLogging,
      'INSERT INTO previousRequests(requestIP, requestDate, requestMethod, requestOriginalURL, appBuild, userId) VALUES (?,?,?,?,?,?)',
      [requestIP, requestDate, requestMethod, requestOriginalURL, appBuild, userId],
    ).catch(
      (error) => {
        serverLogger.error('requestLoggerForRequest error:');
        serverLogger.error(error);
      },
    );
  }

  next();
}

module.exports = { requestLoggerForRequest, createLogForRequest };
