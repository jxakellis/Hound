const { DatabaseError } = require('./errors');
const { logResponse } = require('../logging/logResponse');
const { logServerError } = require('../logging/logServerError');
const { formatNumber, formatBoolean } = require('../format/formatObject');
const { convertErrorToJSON } = require('./errors');
const { areAllDefined } = require('../format/validateDefined');
const { databaseQuery } = require('../database/queryDatabase');
const { poolForRequests } = require('../database/databaseConnections');

async function configureRequestForResponse(req, res, next) {
  res.hasSentResponse = false;
  req.hasActiveConnection = false;
  req.hasActiveTransaction = false;
  req.hasBeenLogged = false;
  res.hasBeenLogged = false;
  configureResponse(req, res);

  const hasActiveConnection = formatBoolean(req.hasActiveConnection);
  const hasActiveTransaction = formatBoolean(req.hasActiveTransaction);

  if (hasActiveConnection === true || hasActiveTransaction === true) {
    return;
  }

  try {
    const requestPoolConnection = await poolForRequests.promise().getConnection();
    req.hasActiveConnection = true;
    try {
      await requestPoolConnection.beginTransaction();
      req.connection = requestPoolConnection.connection;
      req.hasActiveTransaction = true;
    }
    catch (transactionError) {
      res.sendResponseForStatusJSONError(500, undefined, new DatabaseError("Couldn't begin a transaction with request pool connection", global.constant.error.general.POOL_TRANSACTION_FAILED));
      return;
    }
  }
  catch (connectionError) {
    res.sendResponseForStatusJSONError(500, undefined, new DatabaseError("Couldn't create a request pool connection", global.constant.error.general.POOL_CONNECTION_FAILED));
    return;
  }

  next();
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
    if (areAllDefined(hasSentResponse) === false || hasSentResponse === true) {
      return;
    }

    const socketDestroyed = formatBoolean(res && res.socket && res.socket.destroyed);

    if (areAllDefined(socketDestroyed) === false || socketDestroyed === true) {
      return;
    }

    // If we user provided an error, then we convert that error to JSON and use it as the body
    const body = areAllDefined(error)
      ? convertErrorToJSON(error)
      : json;

    logResponse(req, res, body);

    res.hasSentResponse = true;
    res.status(castedStatus).json(body);
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
      logServerError('commitTransaction COMMIT', commitError);
      try {
        await databaseQuery(connection, 'ROLLBACK');
        req.hasActiveTransaction = false;
        // Backup Rollback succeeded
      }
      catch (rollbackError) {
        // Backup ROLLBACK failed, skip COMMIT and ROLLBACK since both failed
        logServerError('commitTransaction ROLLBACK', rollbackError);
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
      logServerError('rollbackTransaction ROLLBACK', rollbackError);
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

module.exports = { configureRequestForResponse };
