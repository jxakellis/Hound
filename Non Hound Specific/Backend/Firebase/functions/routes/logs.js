const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getLogs, createLog, updateLog, deleteLog,
} = require('../controllers/logs');
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
"date":"requiredDate",
"note" : "optionalString",
"logType": "requiredString", // If logType is "Custom", then customTypeName must be provided
"customTypeName":"optionalString"
}
*/

// updates log
router.put('/:logId', updateLog);
/* BODY:

//At least one of the following must be defined: date, note, or logType

{
"date":"optionalDate",
"note" : "optionalString",
"logType": "optionalString", // If logType is "Custom", then customTypeName must be provided
"customTypeName":"optionalString"
}
*/

// deletes log
router.delete('/:logId', deleteLog);
// no body

module.exports = router;