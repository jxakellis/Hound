const { serverLogger } = require('../tools/logging/loggers');
const { verifyDatabaseConnections } = require('../tools/database/verifyDatabaseConnection');
const { testDatabaseConnections } = require('../tools/database/testDatabaseConnection');
const {
  databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests,
} = require('../tools/database/establishDatabaseConnections');
const { restoreAlarmNotificationsForAllFamilies } = require('../tools/notifications/alarm/restoreAlarmNotification');

const configureServerForRequests = (server) => new Promise((resolve) => {
// We can only create an HTTPS server on the AWS instance. Otherwise we create a HTTP server.
  const port = global.constant.server.IS_PRODUCTION_SERVER ? 443 : 80;
  server.listen(port, async () => {
    serverLogger.info(`Running HTTP${global.constant.server.IS_PRODUCTION_SERVER ? 'S' : ''} server on port ${port}; ${global.constant.server.IS_PRODUCTION_DATABASE ? 'production' : 'development'} database`);

    await verifyDatabaseConnections();

    // Test the database connections once every five minutes
    const testDatabaseConnectionIntervalObject = setInterval(() => {
      testDatabaseConnections(databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests)
        .catch((databaseConnectionError) => {
          // If a database connection fails to be able to be tested, meaning it isn't working
          // then we catch the uncaught rejection and instead cause an uncaught exception (causing node to crash)
          throw databaseConnectionError;
        });
    }, global.constant.server.DATABASE_CONNECTION_TEST_INTERVAL);

    if (global.constant.server.IS_PRODUCTION_DATABASE) {
      await restoreAlarmNotificationsForAllFamilies();
    }

    resolve(testDatabaseConnectionIntervalObject);
  });
});

module.exports = { configureServerForRequests };
