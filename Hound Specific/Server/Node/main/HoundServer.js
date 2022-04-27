const bodyParser = require('body-parser');
const express = require('express');
const ParseError = require('../utils/errors/parseError');
const GeneralError = require('../utils/errors/generalError');
const { serverLogger } = require('../utils/logging/pino');

// notification schedule uses a lot listeners, increase this limit as we scale
require('events').EventEmitter.defaultMaxListeners = 100;

const app = express();

const { assignConnection } = require('./databaseConnection');
const userRouter = require('../routes/user');

// parse form data
app.use((req, res, next) => {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json(new ParseError('Unable to parse form data', 'ER_NO_PARSE_FORM_DATA').toJSON);
    }
    return next();
  });
});
app.use(express.urlencoded({ extended: false }));

// parse json
app.use((req, res, next) => {
  bodyParser.json()(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json(new ParseError('Unable to parse json', 'ER_NO_PARSE_JSON').toJSON);
    }

    return next();
  });
});

// router for user requests

/*
/api/v1/user/:userId (OPT)
/api/v1/user/:userId/dogs/:dogId (OPT)
/api/v1/user/:userId/dogs/:dogId/logs/:logId (OPT)
/api/v1/user/:userId/dogs/:dogId/reminders/:reminderId (OPT)
*/

app.use('/', assignConnection);

app.use('/api/v1/user', userRouter);

// unknown path is specified
app.use('*', async (req, res) => {
  // release connection
  await req.rollbackQueries(req);
  return res.status(404).json(new GeneralError('Path not found', 'ER_NOT_FOUND').toJSON);
});

// If we are running a production server, then it should restore restoreAlarmNotificationsForAllFamilies when we restart
const isProduction = false;
const port = 3000;
const { restoreAlarmNotificationsForAllFamilies } = require('../utils/notification/alarm/restoreAlarmNotification');

const server = app.listen(port, () => {
  serverLogger.info(`Listening on port ${port}`);
  // server is freshly restarted so its time to restore notifications that were lost;
  // TO DO re enable me for production
  if (isProduction === true) {
    restoreAlarmNotificationsForAllFamilies();
  }
});

// HoundServer.js is being termianted so we must close connections

const { connectionForNotifications, poolForRequests } = require('./databaseConnection');
const { primarySchedule, secondarySchedule } = require('../utils/notification/alarm/schedules');

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

// Cannot do anything on SIGKILL, causes error
// process.on('SIGKILL', () => {
//  serverLogger.info('SIGKILL');
// shutdown();
// });

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

  primarySchedule.gracefulShutdown()
    .then(() => serverLogger.info('Node Primary Schedule Gracefully Shutdown'))
    .catch((error) => serverLogger.info(`Node Primary Schedule Couldn't Shutdown: ${JSON.stringify(error)}`));

  secondarySchedule.gracefulShutdown()
    .then(() => serverLogger.info('Node Secondary Schedule Gracefully Shutdown'))
    .catch((error) => serverLogger.info(`Node Secondary Schedule Couldn't Shutdown: ${JSON.stringify(error)}`));
};
