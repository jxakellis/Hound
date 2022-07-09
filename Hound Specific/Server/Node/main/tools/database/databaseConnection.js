/* eslint-disable max-len */
const mysql2 = require('mysql2');
const databasePassword = require('../../secrets/databasePassword');
const { DatabaseError } = require('../errors/databaseError');
const { poolLogger, queryLogger } = require('../logging/loggers');

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

const commitQueries = async (req) => {
  try {
    // try to commit the transaction
    // queryLogger.debug(`Attempting To Commit Query For Thread: ${req.connection.threadId}`);
    await req.connection.promise().query('COMMIT');
    // Commit Query Successful
    // queryLogger.debug('Commit Query Successful');
    await req.connection.promise().release();
  }
  catch (error1) {
    // commit failed, now lets roll it back
    queryLogger.error('Commit Query Error:');
    queryLogger.error(error1);
    try {
      await req.connection.promise().query('ROLLBACK');
      // Commit Query With Rollback Successful
      queryLogger.error('Commit Query With Rollback Successful');
      await req.connection.promise().release();
    }
    catch (error2) {
      // rollback failed, release without commiting or rolling back
      queryLogger.error('Commit Query With Rollback Error:');
      queryLogger.error(error2);
      await req.connection.promise().release();
    }
  }
};

const rollbackQueries = async (req) => {
  try {
    await req.connection.promise().query('ROLLBACK');
    // Commit Query With Rollback Successful
    // queryLogger.debug('Rollback Query Successful');
    await req.connection.promise().release();
  }
  catch (error) {
    // rollback failed, release without rolling back
    queryLogger.error('Rollback Query Error:');
    queryLogger.error(error);
    await req.connection.promise().release();
  }
};

const assignConnection = (req, res, next) => {
  poolForRequests.getConnection((error1, connection) => {
    if (error1) {
      //  no need to release connection as there was a failing in actually creating connection
      // DONT ROLLBACK CONNECTION, NOT ASSIGNED
      return res.status(500).json(new DatabaseError("Couldn't create a pool connection", 'ER_NO_POOL_CONNECTION').toJSON);
    }
    else {
      return connection.beginTransaction((error2) => {
        if (error2) {
          req.connection.release();
          return res.status(500).json(new DatabaseError("Couldn't begin a transaction with pool connection", 'ER_NO_POOL_TRANSACTION').toJSON);
        }
        else {
          req.connection = connection;
          req.commitQueries = commitQueries;
          req.rollbackQueries = rollbackQueries;
          return next();
        }
      });
    }
  });
};

module.exports = {
  connectionForGeneral, connectionForLogging, connectionForAlerts, connectionForAlarms, connectionForTokens, poolForRequests, assignConnection,
};
