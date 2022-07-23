const express = require('express');

const { parseFormData, parseJSON } = require('../tools/general/parseBody');
const { requestLoggerForRequest } = require('../tools/logging/requestLogging');
const { configureRequestForResponse, aquirePoolConnectionBeginTransaction } = require('../tools/general/configureRequestAndResponse');
const { validateAppBuild } = require('../tools/format/validateId');
const { userRouter } = require('../../routes/user');
const { GeneralError } = require('../tools/general/errors');

function configureAppForRequests(app) {
  // Setup defaults and custom res.status method
  app.use(configureRequestForResponse);

  // Assign the request a pool connection to use
  app.use(aquirePoolConnectionBeginTransaction);

  // Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Log request and setup logging for response

  app.use(requestLoggerForRequest);

  // Make sure the user is on an updated version

  app.use('/prod/:appBuild', validateAppBuild);

  // Route the request to the userRouter

  app.use('/prod/:appBuild/user', userRouter);

  // Throw back the request if an unknown path is used
  app.use('*', async (req, res) => res.sendResponseForStatusJSONError(404, undefined, new GeneralError('Path not found', global.constant.error.value.INVALID)));
}

module.exports = { configureAppForRequests };
