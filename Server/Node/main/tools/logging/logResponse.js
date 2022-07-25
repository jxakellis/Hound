const { responseLogger } = require('./loggers');
const { logServerError } = require('./logServerError');
const { databaseQuery } = require('../database/databaseQuery');
const { connectionForLogging } = require('../database/databaseConnections');
const { formatBoolean, formatString } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');

// Outputs response to the console and logs to database
function logResponse(req, res, body) {
  const { appBuild } = req.params;
  const { ip, method } = req;

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
      connectionForLogging,
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
