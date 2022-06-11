const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');
const { SERVER_PORT, IS_PRODUCTION } = require('./constants');

const app = express();

// MARK: Create the server

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');
const { cleanUpIsDeleted } = require('../tools/database/cleanUpDatabase');

// Make the server listen on a specific port
const server = app.listen(SERVER_PORT, async () => {
  serverLogger.info(`Listening on port ${SERVER_PORT}`);

  if (IS_PRODUCTION) {
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
  connectionForAlerts, connectionForTokens, poolForRequests,
} = require('../tools/database/databaseConnection');
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
    poolForRequests.end(() => {
      serverLogger.info('Pool For Requests Ended');
    });

    connectionForAlerts.end(() => {
      serverLogger.info('Connection For Alarms Ended');
    });

    connectionForAlerts.end(() => {
      serverLogger.info('Connection For Logs Ended');
    });

    connectionForTokens.end(() => {
      serverLogger.info('Connection For Tokens Ended');
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
