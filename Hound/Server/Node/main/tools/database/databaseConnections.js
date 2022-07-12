const mysql2 = require('mysql2');
const databasePassword = require('../../secrets/databasePassword');
const { poolLogger } = require('../logging/loggers');

/// The connection used by the server when querying the database for log notifications
const connectionForGeneral = mysql2.createConnection({
  connectTimeout: 30000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

/// The connection used by the server when querying the database to add logs about requests
const connectionForLogging = mysql2.createConnection({
  connectTimeout: 30000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

/// The connection used by the server when querying the database for notifications
const connectionForAlerts = mysql2.createConnection({
  connectTimeout: 30000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

/// The connection used by the server when querying the database for notifications
const connectionForAlarms = mysql2.createConnection({
  connectTimeout: 30000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

/// The connection used by the server when querying the database for user tokens
const connectionForTokens = mysql2.createConnection({
  connectTimeout: 30000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

/// the pool used by users when quering the database for their requests
const poolForRequests = mysql2.createPool({
  // Determines the pool's action when no connections are available and the limit has been reached.
  // If true, the pool will queue the connection request and call it when one becomes available.
  // If false, the pool will immediately call back with an error.
  waitForConnections: true,
  // The maximum number of connection requests the pool will queue before returning an error from getConnection.
  // If set to 0, there is no limit to the number of queued connection requests.
  queueLimit: 0,
  // The maximum number of connections to create at once.
  connectionLimit: 10,
  connectTimeout: 10000,
  // acquireTimeout: 10000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

poolForRequests.on('acquire', (connection) => {
  if (global.constant.server.IS_PRODUCTION === false) {
    const currentDate = new Date();
    poolLogger.debug(`Pool connection ${connection.threadId} acquired at H:M:S:ms ${currentDate.getHours()}:${currentDate.getMinutes()}:${currentDate.getSeconds()}:${currentDate.getMilliseconds()}`);
  }
});

poolForRequests.on('release', (connection) => {
  if (global.constant.server.IS_PRODUCTION === false) {
    const currentDate = new Date();
    poolLogger.debug(`Pool connection ${connection.threadId} released at H:M:S:ms ${currentDate.getHours()}:${currentDate.getMinutes()}:${currentDate.getSeconds()}:${currentDate.getMilliseconds()}`);
  }
});

module.exports = {
  connectionForGeneral, connectionForLogging, connectionForAlerts, connectionForAlarms, connectionForTokens, poolForRequests,
};
