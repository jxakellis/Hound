// make sure the constants are loaded
require('./constants');

const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');

const app = express();

// MARK: Create the server

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');
const { cleanUpIsDeleted } = require('../tools/database/databaseCleanUp');

// Make the server listen on a specific port
const server = app.listen(global.constant.server.SERVER_PORT, async () => {
  serverLogger.info(`Listening on port ${global.constant.server.SERVER_PORT}`);

  if (global.constant.server.IS_PRODUCTION) {
    // Server is freshly restarted. Restore notifications that were lost;
    await restoreAlarmNotificationsForAllFamilies();
  }
  await cleanUpIsDeleted();
});

// MARK: Setup the app to process requests

const { configureAppForRequests } = require('./request');

configureAppForRequests(app);

// MARK:  Handle termination of the server

const {
  connectionForGeneral, connectionForLogging, connectionForAlerts, connectionForAlarms, connectionForTokens, poolForRequests,
} = require('../tools/database/databaseConnections');
const { schedule } = require('../tools/notifications/alarm/schedules');

process.on('SIGTERM', () => {
  serverLogger.info('SIGTERM');
  shutdown();
});

process.on('SIGINT', () => {
  // manual kill with ^C
  serverLogger.info('SIGINT');
  shutdown();
});

process.on('SIGUSR2', () => {
  // nodemon restart
  serverLogger.info('SIGUSR2');
  shutdown();
});

/**
 * Gracefully closes/ends everything
 * This includes the connection pool for the database for general requests, the connection for server notifications, the server itself, and the notification schedule
 */
const shutdown = () => {
  serverLogger.info('HoundServer.js Program Is Shutting Down');

  try {
    connectionForGeneral.end(() => {
      serverLogger.info('Connection For General Ended');
    });

    connectionForLogging.end(() => {
      serverLogger.info('Connection For Logging Ended');
    });

    connectionForAlerts.end(() => {
      serverLogger.info('Connection For Alerts Ended');
    });

    connectionForAlarms.end(() => {
      serverLogger.info('Connection For Alarms Ended');
    });

    connectionForTokens.end(() => {
      serverLogger.info('Connection For Tokens Ended');
    });

    poolForRequests.end(() => {
      serverLogger.info('Pool For Requests Ended');
    });

    server.close(() => {
      serverLogger.info('Hound Server Closed');
    });
  }
  catch (error) {
    serverLogger.info(`HoundServer.js Error: ${error}`);
  }

  schedule.gracefulShutdown()
    .then(() => serverLogger.info('Node Schedule Gracefully Shutdown'))
    .catch((error) => serverLogger.info(`Node Primary Schedule Couldn't Shutdown: ${JSON.stringify(error)}`));
};

module.exports = { app };
