const { DatabaseError, convertErrorToJSON } = require('../general/errors');
const { poolForRequests } = require('./databaseConnections');
const { queryLogger } = require('../logging/loggers');
const { areAllDefined } = require('../format/validateDefined');

async function commitQueries(connection) {
  if (areAllDefined(connection) === false) {
    return;
  }

  const usableConnection = areAllDefined(connection.connection)
    ? connection.connection
    : connection;

  try {
    // try to commit the transaction
    // queryLogger.debug(`Attempting To Commit Query For Thread: ${req.connection.threadId}`);
    await usableConnection.promise().query('COMMIT');
    // Commit Query Successful
    // queryLogger.debug('Commit Query Successful');
    await usableConnection.promise().release();
  }
  catch (commitError) {
    // commit failed, now lets roll it back
    queryLogger.error('Commit Query Error:');
    queryLogger.error(commitError);
    try {
      await usableConnection.promise().query('ROLLBACK');
      // Commit Query With Rollback Successful
      queryLogger.error('C_Q Rollback Successful');
      await usableConnection.promise().release();
    }
    catch (rollbackError) {
      // rollback failed, release without commiting or rolling back
      queryLogger.error('C_Q Rollback Error:');
      queryLogger.error(rollbackError);
      try {
        // wrap this so we don't have an escaping error if the .release fails as well
        await usableConnection.promise().release();
      }
      catch (releaseError) {
        queryLogger.error('C_Q R_E Release Error:');
        queryLogger.error(releaseError);
      }
    }
  }
}

async function rollbackQueries(connection) {
  if (areAllDefined(connection) === false) {
    return;
  }

  const usableConnection = areAllDefined(connection.connection)
    ? connection.connection
    : connection;

  try {
    await usableConnection.promise().query('ROLLBACK');
    // Commit Query With Rollback Successful
    // queryLogger.debug('Rollback Query Successful');
    await usableConnection.promise().release();
  }
  catch (rollbackError) {
    // rollback failed, release without rolling back
    queryLogger.error('Rollback Error:');
    queryLogger.error(rollbackError);

    try {
      // wrap this so we don't have an escaping error if the .release fails as well
      await usableConnection.promise().release();
    }
    catch (releaseError) {
      queryLogger.error('R_E Release Error:');
      queryLogger.error(releaseError);
    }
  }
}

function assignDatabaseConnection(req, res, next) {
  poolForRequests.getConnection((connectionError, connection) => {
    if (areAllDefined(connectionError)) {
      //  no need to release connection as there was a failing in actually creating connection
      // DONT ROLLBACK CONNECTION, NOT ASSIGNED
      return res.status(500).json(convertErrorToJSON(new DatabaseError("Couldn't create a pool connection", global.constant.error.general.POOL_CONNECTION_FAILED)));
    }

    return connection.beginTransaction((transactionError) => {
      if (areAllDefined(transactionError)) {
        req.connection.release();
        return res.status(500).json(convertErrorToJSON(new DatabaseError("Couldn't begin a transaction with pool connection", global.constant.error.general.POOL_TRANSACTION_FAILED)));
      }

      req.connection = connection;
      req.commitQueries = commitQueries;
      req.rollbackQueries = rollbackQueries;
      return next();
    });
  });
}

module.exports = { assignDatabaseConnection };
