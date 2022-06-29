const { requestLogger, serverLogger } = require('./loggers');
const { queryPromise } = require('../database/queryPromise');
const { connectionForLogging } = require('../database/databaseConnection');
const { areAllDefined } = require('../format/validateDefined');
const { responseLogger } = require('./loggers');
const { IS_PRODUCTION } = require('../../server/constants');

// Uses requestLogger to output the request from a user in the console
const requestLoggerForRequest = (req, res, next) => {
  if (IS_PRODUCTION === false) {
    requestLogger.info(`Request for ${req.method} ${req.originalUrl}`);
  }

  next();
};

// Inserts request information into the userRequestLogs table. This should only be called after the user is verified.
const createLogForRequest = (req, res, next) => {
  const requestIP = req.ip; // can be undefined
  const requestDate = new Date();
  const requestMethod = req.method;
  const requestOriginalURL = req.originalUrl;
  const appBuild = req.params.appBuild;
  const userId = req.params.userId; // can be undefined

  if (areAllDefined(requestDate, requestMethod, requestOriginalURL, appBuild) && areAllDefined(req.hasBeenLogged) === false) {
    req.hasBeenLogged = true;
    queryPromise(
      connectionForLogging,
      'INSERT INTO userRequestLogs(requestIP, requestDate, requestMethod, requestOriginalURL, appBuild, userId) VALUES (?,?,?,?,?,?)',
      [requestIP, requestDate, requestMethod, requestOriginalURL, appBuild, userId],
    ).catch(
      (error) => {
        serverLogger.error('requestLoggerForRequest error:');
        serverLogger.error(error);
      },
    );
  }

  next();
};

// Uses responseLogger to output the response sent to a user in the console
const responseLoggerForResponse = (req, res, next) => {
  if (IS_PRODUCTION === false) {
    const oldWrite = res.write;
    const oldEnd = res.end;

    const chunks = [];

    res.write = (chunk, ...args) => {
      chunks.push(chunk);
      return oldWrite.apply(res, [chunk, ...args]);
    };

    res.end = (chunk, ...args) => {
      if (chunk) {
        chunks.push(chunk);
      }
      const body = Buffer.concat(chunks).toString('utf8');
      // Log response
      responseLogger.info(`Response for ${req.method} ${req.originalUrl}\n With body: ${body}`);
      return oldEnd.apply(res, [chunk, ...args]);
    };
  }

  next();
};

module.exports = { requestLoggerForRequest, createLogForRequest, responseLoggerForResponse };
