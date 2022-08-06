const { serverLogger } = require('../logging/loggers');
const {
  databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests,
} = require('./establishDatabaseConnections');
const { testDatabaseConnection } = require('./testDatabaseConnection');
const { databaseQuery } = require('./databaseQuery');

async function verifyDatabaseConnections() {
  // First make sure all connetions are connected to the database, then test to make sure they can access a basic table
  await databaseConnectionForGeneral.promise().connect();
  await testDatabaseConnection(databaseConnectionForGeneral);
  serverLogger.info(`databaseConnectionForGeneral connected with thread id ${databaseConnectionForGeneral.threadId}`);

  await databaseConnectionForLogging.promise().connect();
  await testDatabaseConnection(databaseConnectionForLogging);
  serverLogger.info(`databaseConnectionForLogging connected with thread id ${databaseConnectionForLogging.threadId}`);

  await databaseConnectionForAlarms.promise().connect();
  await testDatabaseConnection(databaseConnectionForAlarms);
  serverLogger.info(`databaseConnectionForAlarms connected with thread id ${databaseConnectionForAlarms.threadId}`);

  await testDatabaseConnection(databaseConnectionPoolForRequests);
  serverLogger.info('databaseConnectionPoolForRequests verified as connected');

  // Once all databaseConnections verified, find the number of active threads to the MySQL server
  serverLogger.info(`Currently ${await findNumberOfThreadsConnectedToDatabase(databaseConnectionForGeneral)} threads connected to MySQL`);

  await updateDatabaseConnectionsWaitTimeouts([databaseConnectionForGeneral, databaseConnectionForLogging, databaseConnectionForAlarms, databaseConnectionPoolForRequests]);
}

/// Uses an existing database databaseConnection to find the number of active databaseConnections to said database
async function findNumberOfThreadsConnectedToDatabase(forDatabaseConnection) {
  let threadsConnected = await databaseQuery(
    forDatabaseConnection,
    'SHOW STATUS WHERE variable_name = ?',
    ['Threads_connected'],
  );
  [threadsConnected] = threadsConnected;
  threadsConnected = threadsConnected.Value;
  return threadsConnected;
}

/// Takes an array of database databaseConnections and updates their wait_timeout so the databaseConnections can idle for that number of seconds (before being disconnected)
async function updateDatabaseConnectionsWaitTimeouts(forDatabaseConnections) {
  const promises = [];
  // Iterate through all the databaseConnections
  for (let i = 0; i < forDatabaseConnections.length; i += 1) {
    const databaseConnection = forDatabaseConnections[i];
    // Update the wait_timeout so that the databaseConnections can idle for up to the specified number of seconds (before being killed)
    // This case, we allow the databaseConnection to idle for 7 days
    promises.push(
      databaseQuery(
        databaseConnection,
        'SET session wait_timeout = ?',
        [(60 * 60 * 24 * 7)],
      ),
    );
  }

  await Promise.all(promises);
}

module.exports = { verifyDatabaseConnections, testDatabaseConnection };
