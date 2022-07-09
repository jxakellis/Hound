const express = require('express');

const { parseFormData, parseJSON } = require('./parse');
const { requestLoggerForRequest, responseLoggerForResponse } = require('../tools/logging/requestLogging');
const { assignConnection } = require('../tools/database/databaseConnection');
const { validateAppBuild } = require('../tools/format/validateId');
const { userRouter } = require('../../routes/user');
const { GeneralError } = require('../tools/errors/generalError');

const configureAppForRequests = (app) => {
// Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Log request and setup logging for response

  app.use(requestLoggerForRequest);
  app.use(responseLoggerForResponse);

  // Assign the request a pool connection to use

  app.use(assignConnection);

  // Make sure the user is on an updated version

  app.use('/api/:appBuild', validateAppBuild);

  // Route the request to the userRouter

  app.use('/api/:appBuild/user', userRouter);

  // Throw back the request if an unknown path is used
  app.use('*', async (req, res) => {
  // release connection
    await req.rollbackQueries(req);
    return res.status(404).json(new GeneralError('Path not found', 'ER_NOT_FOUND').toJSON);
  });
};

module.exports = { configureAppForRequests };
