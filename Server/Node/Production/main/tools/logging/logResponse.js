const { responseLogger } = require('./loggers');
const { logServerError } = require('./logServerError');
const { databaseConnectionForLogging } = require('../database/establishDatabaseConnections');
const { databaseQuery } = require('../database/databaseQuery');
const { formatBoolean, formatString, formatNumber } = require('../format/formatObject');

// Outputs response to the console and logs to database
function logResponse(req, res, body) {
  let { appBuild } = req.params;
  let { ip, method } = req;

  appBuild = formatNumber(appBuild);
  appBuild = appBuild > 65535 ? 65535 : appBuild;

  ip = formatString(ip, 32);

  method = formatString(method, 6);

  const requestOriginalUrl = formatString(req.originalUrl, 500);

  const responseBody = formatString(JSON.stringify(body), 500);

  const requestDate = new Date();

  responseLogger.info(`Response for ${req.method} ${requestOriginalUrl}\n With body: ${JSON.stringify(responseBody)}`);

  const hasBeenLogged = formatBoolean(res.hasBeenLogged);

  if (hasBeenLogged === false) {
    res.hasBeenLogged = true;

    databaseQuery(
      databaseConnectionForLogging,
      'INSERT INTO previousResponses(appBuild, requestIP, requestDate, requestMethod, requestOriginalURL, responseBody) VALUES (?,?,?,?,?,?)',
      [appBuild, ip, requestDate, method, requestOriginalUrl, responseBody],
    ).catch(
      (error) => {
        logServerError('logResponse', error);
      },
    );
  }
}

module.exports = { logResponse };
