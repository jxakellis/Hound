const express = require('express')
const router = express.Router({mergeParams: true})

const {getReminders, createReminder, updateReminder, deleteReminder} = require('../controllers/reminders') 
const {validateReminderId} = require('../middleware/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/:reminderId', validateReminderId)



// BASE PATH /api/v1/dog/:userId/:dogId/reminders/....

//gets all reminders
router.get('/',getReminders)
//no body


//gets specific reminder
router.get('/:reminderId',getReminders)
//no body


//create reminder: 
router.post('/',createReminder)
/* BODY:
{"reminderType": "requiredString", 
"customTypeName": "optionalString", 
"timingStyle": "requiredString", 
"executionBasis": "requiredDate",
"enabled":"requiredBool",
"reminderComponent": {
    //FOR countdown (countdown)
    {"executionInterval":"requiredInt"
    "intervalElapsed":"requiredInt"}

    //FOR weekly (timeOfDay), NOTE: skipping date omitted as a reminder cant be skipping when its created
    {"hour":"requiredInt",
    "minute":"requiredInt",
    "sunday":"requiredBool",
    "monday":"requiredBool",
    "tuesday":"requiredBool",
    "wednesday":"requiredBool",
    "thursday":"requiredBool",
    "friday":"requiredBool",
    "saturday":"requiredBool",}

    //FOR monthly (timeOfDay), NOTE: skipping date omitted as a reminder cant be skipping when its created
    {"hour":"requiredInt",
    "minute":"requiredInt",
    "dayOfMonth":"requiredInt"}

    //FOR oneTime (oneTime)
    {"date":"requiredDate"}
}
}
NOTE: If reminderType is "Custom", then customTypeName must be provided
*/


//update reminder
router.put('/:reminderId',updateReminder)
/* BODY:
{"reminderType": "optional", 
"customTypeName": "optionalString", 
"timingStyle": "optional", 
"executionBasis": "optionalDate",
"enabled":"optionalBool",
"reminderComponents": {

    //FOR countdown
    {"executionInterval":"optionalInt"
    "intervalElapsed":"optionalInt"}

    //FOR weekly
    {"hour":"optionalInt",
    "minute":"optionalInt",
    "sunday":"optionalBool",
    "monday":"optionalBool",
    "tuesday":"optionalBool",
    "wednesday":"optionalBool",
    "thursday":"optionalBool",
    "friday":"optionalBool",
    "saturday":"optionalBool",
    "skipping":"optionalBool",
    "skipDate":"optionalDate"}

    //FOR monthly
    {"hour":"optionalInt",
    "minute":"optionalInt",
    "dayOfMonth":"optionalInt",
    skipping":"optionalBool",
    "skipDate":"optionalDate"}

    //FOR oneTime (oneTime)
    {"date":"optionalDate"}
}
}
NOTE: At least one item to update, from all the optionals, must be provided.
NOTE: If reminderType is being updated to "Custom", then customTypeName must be provided
NOTE: If timingStyle is being updated, then ALL reminderComponents required for timingStyle from POST must be provided.
*/


//delete reminder
router.delete('/:reminderId',deleteReminder)
//no body

module.exports = router