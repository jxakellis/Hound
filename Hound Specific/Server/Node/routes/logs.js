const express = require('express')
const router = express.Router({ mergeParams: true })

const { getLogs, createLog, updateLog, deleteLog } = require('../controllers/logs')
const { validateLogId } = require('../middleware/validateId')


//validation that params are formatted correctly and have adequate permissions
router.use('/:logId', validateLogId)



// BASE PATH /api/v1/user/:userId/dogs/:dogId/logs/....

//gets all logs
router.get('/', getLogs)
//no body


//gets specific logs
router.get('/:logId', getLogs)
//no body


//create log
router.post('/', createLog)
/* BODY:
{"date":"requiredDate",
"note" : "optionalString",
"logType": "requiredString",
"customTypeName":"optionalString"
}
NOTE: If logType is "Custom", then customTypeName must be provided
*/


//updates log
router.put('/:logId', updateLog)
/* BODY:
{"date":"optionalDate",
"note" : "optionalString",
"logType": "optionalString",
"customTypeName":"optionalString"
}
NOTE: At least one item to update, from all the optionals, must be provided.
NOTE: If logType is "Custom", then customTypeName must be provided
*/


//deletes log
router.delete('/:logId', deleteLog)
//no body


module.exports = router