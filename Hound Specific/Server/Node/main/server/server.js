const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');
const { SERVER_PORT, IS_PRODUCTION } = require('./constants');

const app = express();

// MARK: Create the server

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');

// Make the server listen on a specific port
const server = app.listen(SERVER_PORT, () => {
  serverLogger.info(`Listening on port ${SERVER_PORT}`);

  if (IS_PRODUCTION) {
    // Server is freshly restarted. Restore notifications that were lost;
    restoreAlarmNotificationsForAllFamilies();
  }
  /**
   *  // TO DO on server start, search through all families.
   * For each family, find the familyId and the oldest lastServerSynchronization of its family members.
   * Then find any dogs, reminders or logs for the family that have IsDeleted true and lastModified older than that lastServerSync
   * Once we find those dogs, reminders, and logs, we can formally delete them.
   * This is because all current users will have synced those changes (indicated by lastServerSync)
   * and new users don't need to know IsDeleted as they won't have a need to delete the data client side.
   *
   * ALSO for saving lastServerSynchronization, use the queryParam from a get all dogs + reminders + logs query
   * Technically will be slightly outdated (as after that query the client-side lastServerSync will be updated to Date())
   * but this only have the downside of temporarily storing data longer than it needs to be stored
   * but with safety of not assume new Date() on server which would be inaccurate by ~10-1000 milliseconds
   */
});

// MARK: Setup the app to process requests

const { configureAppForRequests } = require('./request');

configureAppForRequests(app);

// MARK:  Handle termination of the server

const {
  connectionForAlarms, connectionForGeneralAlerts, connectionForTokens, poolForRequests,
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

    connectionForAlarms.end(() => {
      serverLogger.info('Connection For Alarms Ended');
    });

    connectionForGeneralAlerts.end(() => {
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
