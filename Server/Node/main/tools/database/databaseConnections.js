const mysql2 = require('mysql2');
const {
  developmentHoundUser,
  developmentHoundHost,
  developmentHoundPassword,
  developmentHoundDatabase,
  productionHoundUser,
  productionHoundHost,
  productionHoundPassword,
  productionHoundDatabase,
} = require('../../secrets/databaseCredentials');

const user = global.constant.server.IS_PRODUCTION_DATABASE ? productionHoundUser : developmentHoundUser;
const host = global.constant.server.IS_PRODUCTION_DATABASE ? productionHoundHost : developmentHoundHost;
const password = global.constant.server.IS_PRODUCTION_DATABASE ? productionHoundPassword : developmentHoundPassword;
const database = global.constant.server.IS_PRODUCTION_DATABASE ? productionHoundDatabase : developmentHoundDatabase;
const connectTimeout = 30000;
const connectionConfiguration = {
  user,
  host,
  password,
  database,
  connectTimeout,
};

// TO DO NOW add test loop that re tests the connections to ensure that they are working, if they aren't then initiate a shutdown/crash

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
