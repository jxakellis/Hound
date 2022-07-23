const express = require('express');

const userRouter = express.Router({ mergeParams: true });

const { createLogForRequest } = require('../main/tools/logging/requestLogging');

const {
  getUser, createUser, updateUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../main/tools/format/validateId');

userRouter.param('userId', validateUserId);

// if we have the :userId path param, attempts to create a log using that and the request
userRouter.use('/:userId', createLogForRequest);
// if we are lacking a :userId path param, creates a log without that but with the request
// Note: a request with the :userId path param will both trigger the above .use and this .use
userRouter.use('/', createLogForRequest);

// Route for an alert to send to the suer
const { alertRouter } = require('./alert');

userRouter.use('/:userId/alert', alertRouter);

// Route for family (or nested) related things
const { familyRouter } = require('./family');

userRouter.use('/:userId/family', familyRouter);

// gets user with userIdentifier then return information from users and userConfiguration table
userRouter.get('/', getUser);
// gets user with userId && userIdentifier then return information from users and userConfiguration table
userRouter.get('/:userId', getUser);
// no body

// creates user and userConfiguration
userRouter.post('/', createUser);
/* BODY:
Single: { userInfo }
*/

// updates user
userRouter.put('/:userId', updateUser);
/* BODY:
Single: { userInfo }
*/

module.exports = { userRouter };
