const { requestLogger } = require('./loggers');
const { logServerError } = require('./logServerError');
const { databaseConnectionForLogging } = require('../database/establishDatabaseConnections');
const { databaseQuery } = require('../database/databaseQuery');
const { formatBoolean, formatString, formatNumber } = require('../format/formatObject');

// Outputs request to the console and logs to database
function logRequest(req, res, next) {
  let { appBuild } = req.params;
  let { ip, method } = req;
  const requestDate = new Date();

  appBuild = formatNumber(appBuild);
  appBuild = appBuild > 65535 ? 65535 : appBuild;

  ip = formatString(ip, 32);

  method = formatString(method, 6);

  const requestOriginalUrl = formatString(req.originalUrl, 500);

  requestLogger.info(`Request for ${req.method} ${requestOriginalUrl}`);

  const hasBeenLogged = formatBoolean(req.hasBeenLogged);

  // Inserts request information into the previousRequests table.
  if (hasBeenLogged === false) {
    req.hasBeenLogged = true;
    databaseQuery(
      databaseConnectionForLogging,
      'INSERT INTO previousRequests(appBuild, requestIP, requestDate, requestMethod, requestOriginalURL) VALUES (?,?,?,?,?)',
      [appBuild, ip, requestDate, method, requestOriginalUrl],
    )
      .catch(
        (error) => {
          logServerError('logRequest', error);
        },
      );
  }

  next();
}

module.exports = { logRequest };
