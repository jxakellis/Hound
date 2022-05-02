const { requestLogger } = require('./loggers');

// Logs the request from a user
const logRequest = (req, res, next) => {
  requestLogger.info(`Request for ${req.method} ${req.originalUrl}`);

  next();
};

const { responseLogger } = require('./loggers');

// Logs the response sent to a user
const logResponse = (req, res, next) => {
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

  next();
};

module.exports = { logRequest, logResponse };
