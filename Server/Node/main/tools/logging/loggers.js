const parentLogger = require('pino')();

parentLogger.level = 'debug';

// Logs general server information, unrelated to an individual request
const serverLogger = parentLogger.child({ module: 'Server' });

// Logs requests from users
const requestLogger = parentLogger.child({ module: 'Request' });

// Logs responses sent to users
const responseLogger = parentLogger.child({ module: 'Response' });

// Logs pool connecion aquision and release for requests
const poolLogger = parentLogger.child({ module: 'Pool' });

// Logs functions related to alarms and schedules (e.g. scheduling job for reminder)
const alarmLogger = parentLogger.child({ module: 'Alarm' });

// Logs functions related to general alerts (e.g. someone logged Poty for Fido)
const alertLogger = parentLogger.child({ module: 'Alert' });

// Logs functions related to sending an APN
const apnLogger = parentLogger.child({ module: 'APN' });

module.exports = {
  serverLogger, requestLogger, responseLogger, poolLogger, alarmLogger, alertLogger, apnLogger,
};
