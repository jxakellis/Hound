const express = require('express')
const router = express.Router({mergeParams: true})

const {getLogs, createLog, updateLog, deleteLog} = require('../controllers/logs') 
const {validateLogId} = require('../middleware/validate')

router.use('/:logId', validateLogId)


// /api/v1/dog/logs/....

//gets all logs
router.get('/',getLogs)
//gets specific logs
router.get('/:logId',getLogs)

router.post('/',createLog)

router.put('/:logId',updateLog)

router.delete('/:logId',deleteLog)

module.exports = router