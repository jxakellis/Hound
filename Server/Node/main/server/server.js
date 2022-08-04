// make sure the constants are loaded
require('./constants');
const { exec } = require('child_process');

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

// TO DO NOW upon start of node server, first have it run console commands to stop/start MariaDB

// TO DO NOW add 2fa to AWS
// TO DO NOW add database backups to AWS
// TO DO NOW add watchdog to AWS to make sure node and database are running
// TO DO NOW add PM2 to AWS to better manage the node instance
// TO DO NOW add RDP IP constraints to AWS firewall

const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');
const { configureAppForRequests } = require('./request');
const { logServerError } = require('../tools/logging/logServerError');
const {
  serverConnectionForGeneral, serverConnectionForLogging, serverConnectionForAlarms, poolForRequests,
} = require('../tools/database/databaseConnections');
const { verifyDatabaseConnections } = require('../tools/database/verifyConnections');

// Create a NodeJS HTTPS listener on port that points to the Express app
// We can only create an HTTPS server on the AWS instance. Otherwise we create a HTTP server.
const HTTPOrHTTPSServer = global.constant.server.IS_PRODUCTION_SERVER
  ? https.createServer({
    key: fs.readFileSync('/etc/letsencrypt/live/api.houndorganizer.com/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/api.houndorganizer.com/fullchain.pem'),
  }, app)
  : http.createServer(app);

// We can only create an HTTPS server on the AWS instance. Otherwise we create a HTTP server.
const port = global.constant.server.IS_PRODUCTION_SERVER ? 443 : 80;
HTTPOrHTTPSServer.listen(port, async () => {
  serverLogger.info(`Running HTTP${global.constant.server.IS_PRODUCTION_SERVER ? 'S' : ''} server on port ${port}; ${global.constant.server.IS_PRODUCTION_DATABASE ? 'production' : 'development'} database`);

  await verifyDatabaseConnections();

  if (global.constant.server.IS_PRODUCTION_DATABASE) {
    await restoreAlarmNotificationsForAllFamilies();
    // await cleanUpIsDeleted();
  }
});

// Setup the app to process requests
configureAppForRequests(app);

// MARK:  Handle termination of the server

const { schedule } = require('../tools/notifications/alarm/schedules');

/**
 * Gracefully closes/ends everything
 * This includes the connection pool for the database for general requests, the connection for server notifications, the server itself, and the notification schedule
 */
const shutdown = () => new Promise((resolve) => {
  serverLogger.info('Shutdown Initiated');

  const numberOfShutdownsNeeded = 6;
  let numberOfShutdownsCompleted = 0;

  schedule.gracefulShutdown()
    .then(() => {
      serverLogger.info('Schedule Gracefully Shutdown');
    })
    .catch((error) => {
      serverLogger.error('Schedule Couldn\'t Shutdown', error);
    })
    .finally(() => {
      numberOfShutdownsCompleted += 1;
      checkForShutdownCompletion();
    });

  serverConnectionForGeneral.end((error) => {
    if (error) {
      serverLogger.info('General Server Connection Couldn\'t Shutdown', error);
    }
    else {
      serverLogger.info('General Server Connection Gracefully Shutdown');
    }
    numberOfShutdownsCompleted += 1;
    checkForShutdownCompletion();
  });

  serverConnectionForLogging.end((error) => {
    if (error) {
      serverLogger.info('Logging Server Connection Couldn\'t Shutdown', error);
    }
    else {
      serverLogger.info('Logging Server Connection Gracefully Shutdown');
    }
    numberOfShutdownsCompleted += 1;
    checkForShutdownCompletion();
  });

  serverConnectionForAlarms.end((error) => {
    if (error) {
      serverLogger.info('Alarms Server Connection Couldn\'t Shutdown', error);
    }
    else {
      serverLogger.info('Alarms Server Connection Gracefully Shutdown');
    }
    numberOfShutdownsCompleted += 1;
    checkForShutdownCompletion();
  });

  poolForRequests.end((error) => {
    if (error) {
      serverLogger.info('Pool For Requests Couldn\'t Shutdown', error);
    }
    else {
      serverLogger.info('Pool For Requests Gracefully Shutdown');
    }
    numberOfShutdownsCompleted += 1;
    checkForShutdownCompletion();
  });

  HTTPOrHTTPSServer.close((error) => {
    if (error) {
      serverLogger.info('Server Couldn\'t Shutdown', error);
    }
    else {
      serverLogger.info('Server Gracefully Shutdown');
    }
    numberOfShutdownsCompleted += 1;
    checkForShutdownCompletion();
  });

  function checkForShutdownCompletion() {
    if (numberOfShutdownsCompleted === numberOfShutdownsNeeded) {
      serverLogger.info('Shutdown Complete');
      resolve();
    }
  }
});

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

  if (error.code === 'EADDRINUSE') {
    // The first command is a killall command for linux, the second is for mac
    const consoleCommand = global.constant.server.IS_PRODUCTION_SERVER ? 'sudo killall -9 node' : 'killall -9 node';
    /**
   * The previous Node Application did not shut down properly
   * process.on('exit', ...) isn't called when the process crashes or is killed.
   */
    exec(consoleCommand, () => {
      serverLogger.info('EADDRINUSE; All Node applications killed ');
      process.exit(1);
    });
    return;
  }

  process.exit(1);
});

process.on('uncaughtRejection', async (reason, promise) => {
  // uncaught rejection of a promise happened somewhere
  serverLogger.info(`Uncaught rejection of promise: ${promise}`, `reason: ${reason}`);
});

module.exports = { app };
