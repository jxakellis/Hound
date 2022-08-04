const mysql2 = require('mysql2');
const { databasePassword } = require('../../secrets/databasePassword');

const user = 'admin';
const host = 'localhost';
const password = databasePassword;
const database = global.constant.server.IS_PRODUCTION_DATABASE ? 'productionHound' : 'developmentHound';
const connectTimeout = 30000;
const connectionConfiguration = {
  user,
  host,
  password,
  database,
  connectTimeout,
};

const serverConnectionForGeneral = mysql2.createConnection(connectionConfiguration);

const serverConnectionForLogging = mysql2.createConnection(connectionConfiguration);

const serverConnectionForAlarms = mysql2.createConnection(connectionConfiguration);

/// the pool used by users when quering the database for their requests
const poolForRequests = mysql2.createPool({
  user,
  host,
  password,
  database,
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
});

module.exports = {
  serverConnectionForGeneral, serverConnectionForLogging, serverConnectionForAlarms, poolForRequests,
};
