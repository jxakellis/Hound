const express = require('express');

const { parseFormData, parseJSON } = require('./parse');
const { logRequest, logResponse } = require('../tools/logging/logQuery');
const { assignConnection } = require('../tools/database/databaseConnection');
const userRouter = require('../../routes/user');
const GeneralError = require('../tools/errors/generalError');

const configureAppForRequests = (app) => {
// Parse information possible sent

  app.use(parseFormData);
  app.use(express.urlencoded({ extended: false }));
  app.use(parseJSON);

  // Log request and setup logging for response

  app.use(logRequest);
  app.use(logResponse);

  // Assign the request a pool connection to use

  app.use('/', assignConnection);

  // Route the request to the userRouter

  app.use('/api/v1/user', userRouter);

  // Throw back the request if an unknown path is used
  app.use('*', async (req, res) => {
  // release connection
    await req.rollbackQueries(req);
    return res.status(404).json(new GeneralError('Path not found', 'ER_NOT_FOUND').toJSON);
  });
};

module.exports = { configureAppForRequests };
