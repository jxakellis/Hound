const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getUser, createUser, updateUser, deleteUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../utils/database/validateId');

router.param('userId', validateUserId);

// router.use('/:userId', validateUserId);

// gets user with userIdentifier then return information from users and userConfiguration table
router.get('/', getUser);
// gets user with userId && userIdentifier then return information from users and userConfiguration table
router.get('/:userId', getUser);
// no body

// alert: /api/v1/user/:userId/alert
const alertRouter = require('./alert');

router.use('/:userId/alert', alertRouter);

// family: /api/v1/user/:userId/family
const familyRouter = require('./family');

router.use('/:userId/family', familyRouter);

// BASE PATH /api/v1/user/...

// creates user and userConfiguration
router.post('/', createUser);
/* BODY:
{
  "userIdentifier":"requiredString",
"userEmail":"requiredEmail",
"userFirstName":"requiredString",
"userLastName":"requiredString",
"isNotificationEnabled":"requiredBool",
"isLoudNotification":"requiredBool",
"isFollowUpEnabled":"requiredBool",
"followUpDelay":"requiredInt",
"isCompactView":"requiredBool",
"interfaceStyle":"requiredString",
"snoozeLength":"requiredInt",
"notificationSound":"requiredString"
}
*/

// updates user
router.put('/:userId', updateUser);
/* BODY:

//At least one of the following must be defined: userEmail, userFirstName, userLastName, isNotificationEnabled,
        isLoudNotification, isFollowUpEnabled, followUpDelay, isCompactView,
        interfaceStyle, snoozeLength, or notificationSound

{
"userEmail":"optionalEmail",
"userFirstName":"optionalString",
"userLastName":"optionalString",
"isNotificationEnabled":"optionalBool",
"isLoudNotification":"optionalBool",
"isFollowUpEnabled":"optionalBool",
"followUpDelay":"optionalInt",
"isCompactView":"optionalBool",
"interfaceStyle":"optionalString",
"snoozeLength":"optionalInt",
"notificationSound":"optionalString"
}
*/

// deletes user
router.delete('/:userId', deleteUser);
// no body

module.exports = router;
