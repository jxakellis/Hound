const express = require('express');

const router = express.Router({ mergeParams: true });

const { createLogForRequest } = require('../main/tools/logging/requestLogging');

const {
  getUser, createUser, updateUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../main/tools/format/validateId');

router.param('userId', validateUserId);

// if we have the :userId path param, attempts to create a log using that and the request
router.use('/:userId', createLogForRequest);
// if we are lacking a :userId path param, creates a log without that but with the request
// Note: a request with the :userId path param will both trigger the above .use and this .use
router.use('/', createLogForRequest);

// Route for an alert to send to the suer
const alertRouter = require('./alert');

router.use('/:userId/alert', alertRouter);

// Route for family (or nested) related things
const familyRouter = require('./family');

router.use('/:userId/family', familyRouter);

// gets user with userIdentifier then return information from users and userConfiguration table
router.get('/', getUser);
// gets user with userId && userIdentifier then return information from users and userConfiguration table
router.get('/:userId', getUser);
// no body

// creates user and userConfiguration
router.post('/', createUser);
/* BODY:
Single: { userInfo }
*/

// updates user
router.put('/:userId', updateUser);
/* BODY:
Single: { userInfo }
*/

module.exports = router;
