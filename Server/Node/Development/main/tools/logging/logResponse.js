const { responseLogger } = require('./loggers');
const { logServerError } = require('./logServerError');
const { databaseConnectionForLogging } = require('../database/establishDatabaseConnections');
const { databaseQuery } = require('../database/databaseQuery');
const { formatBoolean, formatString, formatNumber } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');

// Outputs response to the console and logs to database
function logResponse(req, res, body) {
  let { appBuild } = req.params;
  let { ip, method } = req;

  appBuild = formatNumber(appBuild);
  appBuild = appBuild > 65535 ? 65535 : appBuild;

  ip = formatString(ip);
  ip = areAllDefined(ip) ? ip.substring(0, 32) : ip;

  method = formatString(method);
  method = areAllDefined(method) ? method.substring(0, 6) : method;

  let requestOriginalUrl = formatString(req.originalUrl);
  requestOriginalUrl = areAllDefined(requestOriginalUrl) ? requestOriginalUrl.substring(0, 500) : requestOriginalUrl;

  let responseBody = JSON.stringify(body);
  responseBody = responseBody.substring(0, 500);

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
