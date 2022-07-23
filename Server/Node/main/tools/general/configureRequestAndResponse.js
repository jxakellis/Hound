const { formatNumber, formatBoolean } = require('../format/formatObject');
const { DatabaseError, convertErrorToJSON } = require('./errors');
const { poolForRequests } = require('../database/databaseConnections');
const { queryLogger, responseLogger } = require('../logging/loggers');
const { areAllDefined } = require('../format/validateDefined');
const { databaseQuery } = require('../database/databaseQuery');

function configureRequestForResponse(req, res, next) {
  res.hasSentResponse = false;
  req.hasActiveConnection = false;
  req.hasActiveTransaction = false;
  req.hasBeenLogged = false;
  configureResponse(req, res);

  return next();
}

function configureResponse(req, res) {
  res.sendResponseForStatusJSONError = async function sendResponseForStatusJSONError(status, json, error) {
    const hasSentResponse = formatBoolean(res.hasSentResponse);
    const hasActiveConnection = formatBoolean(req.hasActiveConnection);
    const hasActiveTransaction = formatBoolean(req.hasActiveTransaction);
    const castedStatus = formatNumber(status);

    // Check to see if the request has an active connection
    // If it does, then we attempt to COMMIT or ROLLBACK (and if they fail, the functions release() anyways)
    if (hasActiveConnection === true) {
      // if there is no active transaction, then we attempt to release the connection
      if (hasActiveTransaction === false) {
        releaseConnection(req, req.connection, hasActiveConnection);
      }
      else if (castedStatus >= 200 && castedStatus <= 299) {
        // attempt to commit transaction
        await commitTransaction(req, req.connection, hasActiveConnection, hasActiveTransaction);
      }
      else {
        // attempt to rollback transaction
        await rollbackTransaction(req, req.connection, hasActiveConnection, hasActiveTransaction);
      }
    }

    // Check to see if a response has been sent yet
    if (hasSentResponse === true) {
      return;
    }

    // If we user provided an error, then we convert that error to JSON and use it as the body
    const JSONResponse = areAllDefined(error)
      ? convertErrorToJSON(error)
      : json;

    let JSONResponseString = JSON.stringify(JSONResponse);
    JSONResponseString = JSONResponseString.substring(0, 1000);

    if (global.constant.server.IS_PRODUCTION === false) {
      responseLogger.info(`Response for ${req.method} ${req.originalUrl}\n With body: ${JSON.stringify(JSONResponseString)}`);
    }

    res.hasSentResponse = true;
    res.status(castedStatus).json(JSONResponse);
  };
}

async function commitTransaction(req, connection, hasActiveConnection, hasActiveTransaction) {
  const castedHasActiveConnection = formatBoolean(hasActiveConnection);
  const castedHasActiveTransaction = formatBoolean(hasActiveTransaction);
  if (areAllDefined(req, connection, castedHasActiveConnection, castedHasActiveTransaction) === false) {
    return;
  }

  if (castedHasActiveConnection === false) {
    return;
  }

  if (castedHasActiveTransaction === true) {
    try {
      // Attempt to COMMIT the transaction
      await databaseQuery(connection, 'COMMIT');
      req.hasActiveTransaction = false;
    }
    catch (commitError) {
      // COMMIT failed, attempt to rollback
      queryLogger.error(`COMMIT Query Error: ${commitError}`);
      try {
        await databaseQuery(connection, 'ROLLBACK');
        req.hasActiveTransaction = false;
        // Backup Rollback succeeded
        queryLogger.error('C_Q ROLLBACK Successful');
      }
      catch (rollbackError) {
        // Backup ROLLBACK failed, skip COMMIT and ROLLBACK since both failed
        queryLogger.error('C_Q Rollback Error:');
        queryLogger.error(rollbackError);
      }
    }
  }

  releaseConnection(req, connection, castedHasActiveConnection);
}

async function rollbackTransaction(req, connection, hasActiveConnection, hasActiveTransaction) {
  const castedHasActiveConnection = formatBoolean(hasActiveConnection);
  const castedHasActiveTransaction = formatBoolean(hasActiveTransaction);
  if (areAllDefined(req, connection, castedHasActiveConnection, castedHasActiveTransaction) === false) {
    return;
  }

  if (castedHasActiveConnection === false) {
    return;
  }

  if (castedHasActiveTransaction === true) {
    try {
      await databaseQuery(connection, 'ROLLBACK');
      req.hasActiveTransaction = false;
    }
    catch (rollbackError) {
      // ROLLBACK failed, continue as there is nothing we can do
      queryLogger.error(`ROLLBACK Error: ${rollbackError}`);
    }
  }

  releaseConnection(req, connection, castedHasActiveConnection);
}

function releaseConnection(req, connection, hasActiveConnection) {
  const castedHasActiveConnection = formatBoolean(hasActiveConnection);
  if (areAllDefined(req, connection, castedHasActiveConnection) === false || castedHasActiveConnection === false) {
    return;
  }
  // finally, no matter the result above, we release the connection
  connection.release();
  req.hasActiveConnection = false;
}

async function aquirePoolConnectionBeginTransaction(req, res, next) {
  const hasActiveConnection = formatBoolean(req.hasActiveConnection);
  const hasActiveTransaction = formatBoolean(req.hasActiveTransaction);

  if (hasActiveConnection === true || hasActiveTransaction === true) {
    return next();
  }
  try {
    const poolConnection = await poolForRequests.promise().getConnection();
    req.hasActiveConnection = true;
    try {
      await poolConnection.beginTransaction();
      req.connection = poolConnection.connection;
      req.hasActiveTransaction = true;
      return next();
    }
    catch (transactionError) {
      return res.sendResponseForStatusJSONError(500, undefined, new DatabaseError("Couldn't begin a transaction with pool connection", global.constant.error.general.POOL_TRANSACTION_FAILED));
    }
  }
  catch (connectionError) {
    return res.sendResponseForStatusJSONError(500, undefined, new DatabaseError("Couldn't create a pool connection", global.constant.error.general.POOL_CONNECTION_FAILED));
  }
}

module.exports = { configureRequestForResponse, aquirePoolConnectionBeginTransaction };
