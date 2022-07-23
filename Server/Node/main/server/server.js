// make sure the constants are loaded
require('./constants');

// Import builtin NodeJS modules to instantiate the service
const https = require('https');
// const fs = require('fs');

// Import the express module
const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');

// Instantiate an Express application
const app = express();

// MARK: Create the server

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');
const { cleanUpIsDeleted } = require('../tools/database/databaseCleanUp');
const { configureAppForRequests } = require('./request');

// Create a NodeJS HTTPS listener on port that points to the Express app
// Use a callback function to tell when the server is created.
const server = https.createServer(app).listen(global.constant.server.SERVER_PORT, async () => {
  serverLogger.info(`HTTPS server running on port ${global.constant.server.SERVER_PORT}`);

  // TO DO NOW create previousServerErrors table that gets a row every time an async server action fails. E.g. sending an APN.
  // Normal errors get sent back to the user if something fails, but we need to log if there is a server error that isn't sent to the user
  // TO DO NOW review previousRequests table to ensure it is logging everything.
  // TO DO NOW create previousResponses table that gets a row everytime a response is sent
  // Don't store much of the response body as that could take up a lot of space

  if (global.constant.server.IS_PRODUCTION) {
    // Server is freshly restarted. Restore notifications that were lost;
    await restoreAlarmNotificationsForAllFamilies();
  }
  await cleanUpIsDeleted();

  // Setup the app to process requests
  configureAppForRequests(app);
});

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
async function shutdown() {
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

  try {
    await schedule.gracefulShutdown();
    serverLogger.info('Node Schedule Gracefully Shutdown');
  }
  catch (error) {
    serverLogger.error('Node Primary Schedule Couldn\'t Shutdown:');
    serverLogger.error(error);
  }
}

module.exports = { app };
