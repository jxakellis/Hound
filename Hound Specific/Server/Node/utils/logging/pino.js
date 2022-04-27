const parentLogger = require('pino')();

parentLogger.level = 'info';

const serverLogger = parentLogger.child({ module: 'Server' });

// Logs Pool Connection
const poolLogger = parentLogger.child({ module: 'Pool' });

// Logs Queries
const queryLogger = parentLogger.child({ module: 'Query' });

// Logs Alarms
const alarmLogger = parentLogger.child({ module: 'Alarm' });

// Logs Alerts
const alertLogger = parentLogger.child({ module: 'Alert' });

// Logs APN
const apnLogger = parentLogger.child({ module: 'APM' });

module.exports = {
  serverLogger, poolLogger, queryLogger, alarmLogger, alertLogger, apnLogger,
};
