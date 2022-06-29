const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getSubscription, createSubscription,
} = require('../controllers/main/subscription');

//
router.get('/', getSubscription);
// no body

//
router.post('/:encodedReceiptData', createSubscription);
/* BODY:
*/

module.exports = router;
