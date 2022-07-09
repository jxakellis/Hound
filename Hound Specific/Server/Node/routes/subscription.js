const express = require('express');

const subscriptionRouter = express.Router({ mergeParams: true });

const {
  getSubscription, createSubscription,
} = require('../controllers/main/subscription');

//
subscriptionRouter.get('/', getSubscription);
// no body

//
subscriptionRouter.post('/', createSubscription);
/* BODY:
*/

module.exports = { subscriptionRouter };
