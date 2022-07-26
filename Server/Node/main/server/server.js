// make sure the constants are loaded
require('./constants');

// Import builtin NodeJS modules to instantiate the service
const http = require('http');
const https = require('https');
const fs = require('fs');

// Import the express module
const express = require('express');
const { serverLogger } = require('../tools/logging/loggers');

// Instantiate an Express application
const app = express();

// MARK: Create the server

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');
const { cleanUpIsDeleted } = require('../tools/database/databaseCleanUp');
const { configureAppForRequests } = require('./request');
const { logServerError } = require('../tools/logging/logServerError');

// Create a NodeJS HTTPS listener on port that points to the Express app
// If we are in production, then create an HTTPS only server. Otherwise for development, create an HTTP only server.
const HTTPOrHTTPSServer = global.constant.server.IS_PRODUCTION
  ? https.createServer({
    key: fs.readFileSync('/etc/letsencrypt/live/api.houndorganizer.com/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/api.houndorganizer.com/fullchain.pem'),
  }, app)
  : http.createServer(app);

const port = global.constant.server.IS_PRODUCTION ? 443 : 80;
HTTPOrHTTPSServer.listen(port, async () => {
  serverLogger.info(`${global.constant.server.IS_PRODUCTION ? 'Production' : 'Development'} HTTP${port === 443 ? 'S' : ''} server running on port ${port}`);

  if (global.constant.server.IS_PRODUCTION) {
    await restoreAlarmNotificationsForAllFamilies();
    await cleanUpIsDeleted();
  }
});

// Setup the app to process requests
configureAppForRequests(app);

// MARK:  Handle termination of the server

const {
  connectionForGeneral, connectionForLogging, connectionForAlerts, connectionForAlarms, connectionForTokens, poolForRequests,
} = require('../tools/database/databaseConnections');
const { schedule } = require('../tools/notifications/alarm/schedules');

process.on('SIGTERM', async () => {
  serverLogger.info('SIGTERM');
  await shutdown();
});

process.on('SIGINT', async () => {
  // manual kill with ^C
  serverLogger.info('SIGINT');
  await shutdown();
});

process.on('SIGUSR2', async () => {
  // nodemon restart
  serverLogger.info('SIGUSR2');
  await shutdown();
});

process.on('uncaughtException', async (error, origin) => {
  // uncaught error happened somewhere
  serverLogger.info(`Uncaught exception from origin: ${origin}`);
  await logServerError('uncaughtException', error);
  await shutdown();

  throw error;
});

process.on('uncaughtRejection', async (reason, promise) => {
  // uncaught rejection of a promise happened somewhere
  serverLogger.info(`Uncaught rejection of promise: ${promise}`, `reason: ${reason}`);
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

    HTTPOrHTTPSServer.close(() => {
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
