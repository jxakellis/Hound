const { serverLogger } = require('../logging/loggers');
const {
  serverConnectionForGeneral, serverConnectionForLogging, serverConnectionForAlarms, poolForRequests,
} = require('./databaseConnections');
const { databaseQuery } = require('./queryDatabase');

async function verifyDatabaseConnections() {
  // First make sure all connetions are connected to the database, then test to make sure they can access a basic table
  await serverConnectionForGeneral.promise().connect();
  await serverConnectionForGeneral.promise().query('SELECT * FROM users LIMIT 1');
  serverLogger.info(`serverConnectionForGeneral connected with thread id ${serverConnectionForGeneral.threadId}`);

  await serverConnectionForLogging.promise().connect();
  await serverConnectionForLogging.promise().query('SELECT * FROM users LIMIT 1');
  serverLogger.info(`serverConnectionForLogging connected with thread id ${serverConnectionForLogging.threadId}`);

  await serverConnectionForAlarms.promise().connect();
  await serverConnectionForAlarms.promise().query('SELECT * FROM users LIMIT 1');
  serverLogger.info(`serverConnectionForAlarms connected with thread id ${serverConnectionForAlarms.threadId}`);

  await poolForRequests.promise().query('SELECT * FROM users LIMIT 1');
  serverLogger.info('poolForRequests verified as connected');

  // Once all connections verified, find the number of active threads to the MySQL server
  let threadsConnected = await databaseQuery(
    serverConnectionForGeneral,
    'SHOW STATUS WHERE variable_name = ?',
    ['Threads_connected'],
  );
  [threadsConnected] = threadsConnected;
  threadsConnected = threadsConnected.Value;
  serverLogger.info(`Currently ${threadsConnected} threads connected to MySQL`);

  const connections = [serverConnectionForGeneral, serverConnectionForLogging, serverConnectionForAlarms, poolForRequests];
  const promises = [];
  // Iterate through all the connections
  for (let i = 0; i < connections.length; i += 1) {
    const connection = connections[i];
    // Update the wait_timeout so that the connections can idle for up to the specified number of seconds (before being killed)
    // This case, we allow the connection to idle for 7 days
    promises.push(
      databaseQuery(
        connection,
        'SET session wait_timeout = ?',
        [(60 * 60 * 24 * 7)],
      ),
    );
  }

  await Promise.all(promises);
}

module.exports = { verifyDatabaseConnections };
