const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getUser, createUser, updateUser, deleteUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../main/tools/format/validateId');

router.param('userId', validateUserId);

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

// deletes user
router.delete('/:userId', deleteUser);
// no body

module.exports = router;
