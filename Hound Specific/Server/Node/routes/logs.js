const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getLogs, createLog, updateLog, deleteLog,
} = require('../controllers/main/logs');
const { validateLogId } = require('../main/tools/validation/validateId');

// validation that params are formatted correctly and have adequate permissions
router.param('logId', validateLogId);

// gets all logs
router.get('/', getLogs);
// no body

// gets specific logs
router.get('/:logId', getLogs);
// no body

// create log
router.post('/', createLog);
/* BODY:
Single: { logInfo }
*/

// updates log
router.put('/:logId', updateLog);
/* BODY:
Single: { logInfo }
*/

// deletes log
router.delete('/:logId', deleteLog);
// no body

module.exports = router;
