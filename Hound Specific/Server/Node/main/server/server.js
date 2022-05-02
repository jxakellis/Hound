const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');

const app = express();

// MARK: Create the server

const isProduction = true;
const port = 3000;
const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');

// Make the server listen on a specific port
const server = app.listen(port, () => {
  serverLogger.info(`Listening on port ${port}`);

  // TO DO re enable me for production
  if (isProduction === true) {
    // Server is freshly restarted. Restore notifications that were lost;
    restoreAlarmNotificationsForAllFamilies();
  }
});

// MARK: Setup the app to process requests

const { configureAppForRequests } = require('./request');

configureAppForRequests(app);

// MARK:  Handle termination of the server

const { connectionForNotifications, poolForRequests } = require('../tools/database/databaseConnection');
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

    connectionForNotifications.end(() => {
      serverLogger.info('Connection For Notifications Ended');
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
