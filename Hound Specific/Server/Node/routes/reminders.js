const express = require('express')
const router = express.Router({ mergeParams: true })

const { getReminders, createReminder, updateReminder, deleteReminder } = require('../controllers/reminders')
const { validateReminderId } = require('../utils/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/:reminderId', validateReminderId)



// BASE PATH /api/v1/user/:userId/dogs/:dogId/reminders/...

//gets all reminders
router.get('/', getReminders)
//no body


//gets specific reminder
router.get('/:reminderId', getReminders)
//no body


//create reminder: 
router.post('/', createReminder)
/* BODY:
{
"reminderType": "requiredString", // If reminderType is "Custom", then customTypeName must be provided
"customTypeName": "optionalString", 
"timingStyle": "requiredString", //Only components for timingStyle type specified must be provided
"executionBasis": "requiredDate",
"isEnabled":"requiredBool",

    //FOR countdown
    "countdownExecutionInterval":"requiredInt",
    "countdownIntervalElapsed":"requiredInt"

    //FOR weekly, NOTE: skipping date omitted as a reminder cant be skipping when its created
    "hour":"requiredInt",
    "minute":"requiredInt",
    "sunday":"requiredBool",
    "monday":"requiredBool",
    "tuesday":"requiredBool",
    "wednesday":"requiredBool",
    "thursday":"requiredBool",
    "friday":"requiredBool",
    "saturday":"requiredBool",

    //FOR monthly, NOTE: skipping date omitted as a reminder cant be skipping when its created
    "hour":"requiredInt",
    "minute":"requiredInt",
    "dayOfMonth":"requiredInt"

    //FOR oneTime
    "date":"requiredDate"

    //FOR snooze
    no snooze components in creation, only when actually snoozed
}
}
*/


//update reminder
router.put('/:reminderId', updateReminder)
/* BODY:

//At least one of the following must be defined: reminderType, timingStyle, executionBasis, isEnabled, or isSnoozed 

{
"reminderType": "optionalString", // If reminderType is "Custom", then customTypeName must be provided
"customTypeName": "optionalString", 
"timingStyle": "optionalString", //If timingStyle provided, then all components for timingStyle type must be provided
"executionBasis": "optionalDate",
"isEnabled":"optionalBool",

    //components only required if timingStyle provided

    //FOR countdown
    "countdownExecutionInterval":"requiredInt",
    "countdownIntervalElapsed":"requiredInt"

    //FOR weekly
    "hour":"requiredInt",
    "minute":"requiredInt",
    "sunday":"requiredBool",
    "monday":"requiredBool",
    "tuesday":"requiredBool",
    "wednesday":"requiredBool",
    "thursday":"requiredBool",
    "friday":"requiredBool",
    "saturday":"requiredBool",
    "skipping":"optionalBool", //if skipping is provided, then skipDate is required
    "skipDate":"optionalDate"

    //FOR monthly
    "hour":"requiredInt",
    "minute":"requiredInt",
    "dayOfMonth":"requiredInt"
    "skipping":"optionalBool", //if skipping is provided, then skipDate is required
    "skipDate":"optionalDate"

    //FOR oneTime
    "date":"requiredDate"

    //FOR snooze
    "isSnoozed":"requiredBool",
    "snoozeExecutionInterval":"optionalInt", //if isSnoozed is true, then snoozeExecutionInterval and snoozeIntervalElapsed are required
    "snoozeIntervalElapsed":"optionalInt"
}
}
*/


//delete reminder
router.delete('/:reminderId', deleteReminder)
//no body

module.exports = router