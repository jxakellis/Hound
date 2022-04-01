/* eslint-disable max-len */
const mysql = require('mysql');
const databasePassword = require('./databasePassword');
const DatabaseError = require('./utils/errors/databaseError');

const pool = mysql.createPool({
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
  acquireTimeout: 10000,
  host: 'localhost',
  user: 'admin',
  password: databasePassword,
  database: 'Hound',
});

pool.on('acquire', (connection) => {
  const date = new Date();
  console.log(`Connection ${connection.threadId} acquired at H:M:S:ms ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}:${date.getMilliseconds()}`);
});

pool.on('release', (connection) => {
  const date = new Date();
  console.log(`Connection ${connection.threadId} released at H:M:S:ms ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}:${date.getMilliseconds()}`);
});

const commitQueries = (req) => {
  req.connection.commit((error) => {
    if (error) {
      console.log(`Commit Query Error: ${error}`);
    }
  });
  req.connection.release();
};

const rollbackQueries = (req) => {
  req.connection.rollback((error) => {
    if (error) {
      console.log(`Rollback Query Error: ${error}`);
    }
  });
  req.connection.release();
};

const assignConnection = async (req, res, next) => {
  pool.getConnection((error, connection) => {
    if (error) {
      // no need to release connection as there was a failing in actually creating connection
      res.status(500).json(new DatabaseError("Couldn't create a pool connection", 'ER_NO_POOL_CONNECTION').toJSON);
    }
    else {
      connection.beginTransaction((error2) => {
        if (error2) {
          connection.release();
          res.status(500).json(new DatabaseError("Couldn't begin a transaction with pool connection", 'ER_NO_POOL_TRANSACTION').toJSON);
        }
        else {
          req.connection = connection;
          req.commitQueries = commitQueries;
          req.rollbackQueries = rollbackQueries;
          next();
        }
      });
    }
  });
};

module.exports = { assignConnection };
