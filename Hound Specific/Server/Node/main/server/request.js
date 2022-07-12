const express = require('express');

const { parseFormData, parseJSON } = require('./parse');
const { requestLoggerForRequest, responseLoggerForResponse } = require('../tools/logging/requestLogging');
const { assignDatabaseConnection } = require('../tools/database/databaseConnections');
const { validateAppBuild } = require('../tools/format/validateId');
const { userRouter } = require('../../routes/user');
const { GeneralError, convertErrorToJSON } = require('../tools/general/errors');

const configureAppForRequests = (app) => {
// Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Log request and setup logging for response

  app.use(requestLoggerForRequest);
  app.use(responseLoggerForResponse);

  // Assign the request a pool connection to use

  app.use(assignDatabaseConnection);

  // Make sure the user is on an updated version

  app.use('/api/:appBuild', validateAppBuild);

  // Route the request to the userRouter

  app.use('/api/:appBuild/user', userRouter);

  // Throw back the request if an unknown path is used
  app.use('*', async (req, res) => {
  // release connection
    await req.rollbackQueries(req);
    return res.status(404).json(convertErrorToJSON(new GeneralError('Path not found', global.constant.error.value.INVALID)));
  });
};

module.exports = { configureAppForRequests };
