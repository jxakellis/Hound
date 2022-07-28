const express = require('express');

const { parseFormData, parseJSON } = require('../tools/general/parseBody');
const { logRequest } = require('../tools/logging/logRequest');
const { configureRequestForResponse, aquirePoolConnectionBeginTransaction } = require('../tools/general/configureRequestAndResponse');
const { validateAppBuild } = require('../tools/format/validateId');
const { serverToServerRouter } = require('../../routes/serverToServer');
const { userRouter } = require('../../routes/user');
const { GeneralError } = require('../tools/general/errors');

const databasePath = global.constant.server.IS_PRODUCTION_DATABASE ? 'prod' : 'dev';
const serverToServerPath = `/${databasePath}/s2s`;
const userPath = `/${databasePath}/app/:appBuild`;

function configureAppForRequests(app) {
  // Setup defaults and custom res.status method
  app.use(configureRequestForResponse);

  // Assign the request a pool connection to use
  app.use(aquirePoolConnectionBeginTransaction);

  // Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Check to see if the request is a server to server communication from Apple
  app.use(serverToServerPath, serverToServerRouter);

  // Log request and setup logging for response

  app.use(userPath, logRequest);

  // Make sure the user is on an updated version

  app.use(userPath, validateAppBuild);

  // Route the request to the userRouter

  app.use(`${userPath}/user`, userRouter);

  // Throw back the request if an unknown path is used
  app.use('*', async (req, res) => res.sendResponseForStatusJSONError(404, undefined, new GeneralError('Path not found', global.constant.error.value.INVALID)));
}

module.exports = { configureAppForRequests };
