const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getReminders, createReminder, updateReminder, deleteReminder,
} = require('../controllers/main/reminders');
const { validateParamsReminderId, validateBodyReminderId } = require('../main/tools/validation/validateId');

// No need to validate body for get ( no body exists )
// No need to validate body for create ( there are no passed reminders )
// Validate body for put at specific route
// Validate body for delete at specific route

router.param('reminderId', validateParamsReminderId);
// validation that params are formatted correctly and have adequate permissions
// router.use('/:reminderId', validateParamsReminderId);

// BASE PATH /api/v1/user/:userId/dogs/:dogId/reminders/...

// gets all reminders
router.get('/', getReminders);
// no body

// gets specific reminder
router.get('/:reminderId', getReminders);
// no body

// create reminder(s)
router.post('/', createReminder);
/* BODY:
Single: { reminderInfo }
Multiple: { reminders: [reminderInfo1, reminderInfo2...] }

reminderInfo:
*/

// update reminder(s)
router.put('/', validateBodyReminderId, updateReminder);
// router.put('/:reminderId', updateReminder);
/* BODY:
Single: { reminderInfo }
Multiple: { reminders: [reminderInfo1, reminderInfo2...] }
*/

// delete reminder(s)
router.delete('/', validateBodyReminderId, deleteReminder);
// router.delete('/:reminderId', deleteReminder);
/* BODY:
Single: { reminderId }
Multiple: { reminders: [reminderId1, reminderId2...] }
*/

/*
Reminder Info:
{
"reminderAction": "requiredString", // If reminderAction is "Custom", then reminderCustomActionName must be provided
"reminderCustomActionName": "optionalString",
"reminderType": "requiredString", //Only components for reminderType type specified must be provided
"reminderExecutionBasis": "requiredDate",
"reminderIsEnabled":"requiredBool",

    //FOR countdown
    "countdownExecutionInterval":"requiredInt",
    "countdownIntervalElapsed":"requiredInt"

    //FOR weekly
    "weeklyHour":"requiredInt",
    "weeklyMinute":"requiredInt",
    "sunday":"requiredBool",
    "monday":"requiredBool",
    "tuesday":"requiredBool",
    "wednesday":"requiredBool",
    "thursday":"requiredBool",
    "friday":"requiredBool",
    "saturday":"requiredBool",
    "weeklyIsSkipping":"requiredBool",
    "weeklyIsSkippingDate":"optionalDate"

    //FOR monthly
    "monthlyHour":"requiredInt",
    "monthlyMinute":"requiredInt",
    "monthlyDay":"requiredInt"
    "weeklyIsSkipping":"requiredBool",
    "monthlyIsSkippingDate":"optionalDate"

    //FOR oneTime
    "logDate":"requiredDate"

    //FOR snooze
    "snoozeIsEnabled":"requiredBool",
    "snoozeExecutionInterval":"optionalInt", //if snoozeIsEnabled is true, then snoozeExecutionInterval and snoozeIntervalElapsed are required
    "snoozeIntervalElapsed":"optionalInt"
}
*/

module.exports = router;
