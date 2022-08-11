const express = require('express');

const subscriptionRouter = express.Router({ mergeParams: true });

const {
  getInAppSubscriptions, createInAppSubscription,
} = require('../controllers/controllerRoutes/inAppSubscriptions');

//
subscriptionRouter.get('/', getInAppSubscriptions);
// no body

//
subscriptionRouter.post('/', createInAppSubscription);
/* BODY:
*/

module.exports = { subscriptionRouter };
