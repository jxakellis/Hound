const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getUser, createUser, updateUser, deleteUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../utils/validateId');

// gets user with userId then return information from users and userConfiguration table
router.get('/:userId', getUser);
// no body

// validation that params are formatted correctly and have adequate permissions.
// This check HAS to be after the .get for /user.
// Otherwise if the user passes a userIdentifier to get their userId, it will fail as format incorrect
router.use('/:userId', validateUserId);

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
"isPaused":"requiredBool",
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
        isLoudNotification, isFollowUpEnabled, followUpDelay, isPaused, isCompactView,
        interfaceStyle, snoozeLength, or notificationSound

{
"userEmail":"optionalEmail",
"userFirstName":"optionalString",
"userLastName":"optionalString",
"isNotificationEnabled":"optionalBool",
"isLoudNotification":"optionalBool",
"isFollowUpEnabled":"optionalBool",
"followUpDelay":"optionalInt",
"isPaused":"optionalBool",
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
