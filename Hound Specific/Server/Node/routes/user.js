const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getUser, createUser, updateUser, deleteUser,
} = require('../controllers/main/user');

const { validateUserId } = require('../main/tools/validation/validateId');

router.param('userId', validateUserId);

// router.use('/:userId', validateUserId);

// gets user with userIdentifier then return information from users and userConfiguration table
router.get('/', getUser);
// gets user with userId && userIdentifier then return information from users and userConfiguration table
router.get('/:userId', getUser);
// no body

const alertRouter = require('./alert');

router.use('/:userId/alert', alertRouter);

const familyRouter = require('./family');

router.use('/:userId/family', familyRouter);

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
"logsInterfaceScale":"requiredBool",
"remindersInterfaceScale":"requiredBool",
"interfaceStyle":"requiredString",
"snoozeLength":"requiredInt",
"notificationSound":"requiredString"
}
*/

// updates user
router.put('/:userId', updateUser);
/* BODY:

//At least one of the following must be defined: userEmail, userFirstName, userLastName, isNotificationEnabled,
        isLoudNotification, isFollowUpEnabled, followUpDelay, logsInterfaceScale, remindersInterfaceScale,
        interfaceStyle, snoozeLength, or notificationSound

{
"userEmail":"optionalEmail",
"userFirstName":"optionalString",
"userLastName":"optionalString",
"isNotificationEnabled":"optionalBool",
"isLoudNotification":"optionalBool",
"isFollowUpEnabled":"optionalBool",
"followUpDelay":"optionalInt",
"logsInterfaceScale":"optionalBool",
"remindersInterfaceScale":"optionalBool",
"interfaceStyle":"optionalString",
"snoozeLength":"optionalInt",
"notificationSound":"optionalString"
}
*/

// deletes user
router.delete('/:userId', deleteUser);
// no body

module.exports = router;
