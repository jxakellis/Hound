const express = require('express');

const { parseFormData, parseJSON } = require('../tools/general/parseBody');
const { logRequest } = require('../tools/logging/logRequest');
const { configureRequestForResponse } = require('../tools/general/configureRequestAndResponse');
const { validateAppBuild } = require('../tools/format/validateId');
const { appStoreServerNotificationRouter } = require('../../routes/appStoreServerNotifications');
const { userRouter } = require('../../routes/user');
const { GeneralError } = require('../tools/general/errors');

const databasePath = global.constant.server.IS_PRODUCTION_DATABASE ? 'prod' : 'dev';
const serverToServerPath = `/${databasePath}/appStoreServerNotifications`;
const userPath = `/${databasePath}/app/:appBuild`;

function configureAppForRequests(app) {
  // Setup defaults and custom res.status method
  app.use(configureRequestForResponse);

  // Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Check to see if the request is a server to server communication from Apple
  app.use(serverToServerPath, appStoreServerNotificationRouter);

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
