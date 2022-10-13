const { requestLogger } = require('./loggers');
const { logServerError } = require('./logServerError');
const { databaseConnectionForLogging } = require('../database/establishDatabaseConnections');
const { databaseQuery } = require('../database/databaseQuery');
const { areAllDefined } = require('../format/validateDefined');
const { formatString, formatNumber } = require('../format/formatObject');

// Outputs request to the console and logs to database
async function logRequest(req, res, next) {
  // TO DO NOW before a request insert, check the total number of requests and responses, if that number is over ~10 million, then delete the first 100,000
  const date = new Date();

  const appVersion = formatString(req.params.appVersio, 10);

  const ip = formatString(req.ip, 32);

  const method = formatString(req.method, 6);

  const originalUrl = formatString(req.originalUrl, 500);

  requestLogger.info(`Request for ${method} ${originalUrl}`);

  // Inserts request information into the previousRequests table.
  if (areAllDefined(req.requestId) === false) {
    try {
      const result = await databaseQuery(
        databaseConnectionForLogging,
        'INSERT INTO previousRequests(requestAppVersion, requestIP, requestDate, requestMethod, requestOriginalURL) VALUES (?,?,?,?,?)',
        [appVersion, ip, date, method, originalUrl],
      );
      const requestId = formatNumber(result.insertId);
      req.requestId = requestId;
    }
    catch (error) {
      logServerError('logRequest', error);
    }
  }

  next();
}

module.exports = { logRequest };
