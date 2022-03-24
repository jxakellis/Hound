const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getReminders, createReminder, updateReminder, deleteReminder,
} = require('../controllers/reminders');
const { validateReminderId } = require('../utils/validateId');

// validation that params are formatted correctly and have adequate permissions
router.use('/:reminderId', validateReminderId);

// BASE PATH /api/v1/user/:userId/dogs/:dogId/reminders/...

// gets all reminders
router.get('/', getReminders);
// no body

// gets specific reminder
router.get('/:reminderId', getReminders);
// no body

// create reminder:
router.post('/', createReminder);
/* BODY:
{
"reminderAction": "requiredString", // If reminderAction is "Custom", then customTypeName must be provided
"customTypeName": "optionalString",
"reminderType": "requiredString", //Only components for reminderType type specified must be provided
"executionBasis": "requiredDate",
"isEnabled":"requiredBool",

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
    "weeklySkipDate":"optionalDate"

    //FOR monthly
    "monthlyHour":"requiredInt",
    "monthlyMinute":"requiredInt",
    "dayOfMonth":"requiredInt"
    "weeklyIsSkipping":"requiredBool",
    "monthlySkipDate":"optionalDate"

    //FOR oneTime
    "date":"requiredDate"

    //FOR snooze
    no snooze components in creation, only when actually snoozed
}
}
*/

// update reminder
router.put('/:reminderId', updateReminder);
/* BODY:

//At least one of the following must be defined: reminderAction, reminderType, executionBasis, isEnabled, or isSnoozed

{
"reminderAction": "optionalString", // If reminderAction is "Custom", then customTypeName must be provided
"customTypeName": "optionalString",
"reminderType": "optionalString", //If reminderType provided, then all components for reminderType type must be provided
"executionBasis": "optionalDate",
"isEnabled":"optionalBool",

    //components only required if reminderType provided

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
    "weeklyIsSkipping":"optionalBool", //if weeklyIsSkipping is provided, then weeklySkipDate is required
    "weeklySkipDate":"optionalDate"

    //FOR monthly
    "monthlyHour":"requiredInt",
    "monthlyMinute":"requiredInt",
    "dayOfMonth":"requiredInt"
    "monthlyIsSkipping":"optionalBool", //if monthlyIsSkipping is provided, then monthlySkipDate is required
    "weeklySkipDate":"optionalDate"

    //FOR oneTime
    "date":"requiredDate"

    //FOR snooze
    "isSnoozed":"requiredBool",
    "snoozeExecutionInterval":"optionalInt", //if isSnoozed is true, then snoozeExecutionInterval and snoozeIntervalElapsed are required
    "snoozeIntervalElapsed":"optionalInt"
}
}
*/

// delete reminder
router.delete('/:reminderId', deleteReminder);
// no body

module.exports = router;
