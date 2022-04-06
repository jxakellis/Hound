const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getLogs, createLog, updateLog, deleteLog,
} = require('../controllers/main/logs');
const { validateLogId } = require('../utils/validateId');

// validation that params are formatted correctly and have adequate permissions
router.use('/:logId', validateLogId);

// BASE PATH /api/v1/user/:userId/dogs/:dogId/logs/...

// gets all logs
router.get('/', getLogs);
// no body

// gets specific logs
router.get('/:logId', getLogs);
// no body

// create log
router.post('/', createLog);
/* BODY:
{
"logDate":"requiredDate",
"logNote" : "optionalString",
"logAction": "requiredString", // If logAction is "Custom", then customActionName must be provided
"customActionName":"optionalString"
}
*/

// updates log
router.put('/:logId', updateLog);
/* BODY:

//At least one of the following must be defined: logDate, logNote, or logAction

{
"logDate":"optionalDate",
"logNote" : "optionalString",
"logAction": "optionalString", // If logAction is "Custom", then customActionName must be provided
"customActionName":"optionalString"
}
*/

// deletes log
router.delete('/:logId', deleteLog);
// no body

module.exports = router;
