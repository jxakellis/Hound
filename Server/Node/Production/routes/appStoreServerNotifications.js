const express = require('express');

const appStoreServerNotificationRouter = express.Router({ mergeParams: true });

const {
  createAppStoreServerNotification,
} = require('../controllers/controllerRoutes/appStoreServerNotifications');

appStoreServerNotificationRouter.post('/', createAppStoreServerNotification);

module.exports = { appStoreServerNotificationRouter };
