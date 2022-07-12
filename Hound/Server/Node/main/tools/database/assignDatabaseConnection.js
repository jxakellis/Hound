const { DatabaseError, convertErrorToJSON } = require('../general/errors');
const { poolForRequests } = require('./databaseConnections');
const { queryLogger } = require('../logging/loggers');

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

const assignDatabaseConnection = (req, res, next) => {
  poolForRequests.getConnection((error1, connection) => {
    if (error1) {
      //  no need to release connection as there was a failing in actually creating connection
      // DONT ROLLBACK CONNECTION, NOT ASSIGNED
      return res.status(500).json(convertErrorToJSON(new DatabaseError("Couldn't create a pool connection", global.constant.error.general.POOL_CONNECTION_FAILED)));
    }
    else {
      return connection.beginTransaction((error2) => {
        if (error2) {
          req.connection.release();
          return res.status(500).json(convertErrorToJSON(new DatabaseError("Couldn't begin a transaction with pool connection", global.constant.error.general.POOL_TRANSACTION_FAILED)));
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

module.exports = { assignDatabaseConnection };
