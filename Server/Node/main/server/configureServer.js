const { serverLogger } = require('../tools/logging/loggers');
const { verifyDatabaseConnections } = require('../tools/database/verifyDatabaseConnection');
const { testDatabaseConnections } = require('../tools/database/testDatabaseConnection');
const {
  databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests,
} = require('../tools/database/establishDatabaseConnections');
const { logServerError } = require('../tools/logging/logServerError');
const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');

const configureServerForRequests = (server) => new Promise((resolve) => {
// We can only create an HTTPS server on the AWS instance. Otherwise we create a HTTP server.
  server.listen(global.constant.server.SERVER_PORT, async () => {
    serverLogger.info(`Running HTTP${global.constant.server.IS_PRODUCTION_SERVER ? 'S' : ''} server on port ${global.constant.server.SERVER_PORT}; ${global.constant.server.IS_PRODUCTION_DATABASE ? 'production' : 'development'} database`);

    await verifyDatabaseConnections();

    // Test the database connections once every five minutes
    const testDatabaseConnectionIntervalObject = setInterval(() => {
      testDatabaseConnections(databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests)
        .catch((databaseConnectionError) => {
          /*
            If a database connection fails its test, it means there is a problem.
            We attempt to log this problem
            However, the logServerError will probably fail as well, as
            it requires a database connection to insert the log into the table.
            If this happens, the failure is caught and output to console
          */
          logServerError(databaseConnectionError);
        });
    }, global.constant.server.DATABASE_CONNECTION_TEST_INTERVAL);

    if (global.constant.server.IS_PRODUCTION_DATABASE) {
      await restoreAlarmNotificationsForAllFamilies();
    }

    resolve(testDatabaseConnectionIntervalObject);
  });
});

module.exports = { configureServerForRequests };
