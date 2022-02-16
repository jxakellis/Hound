const express = require('express')
const router = express.Router({ mergeParams: true })

const { getDogs, createDog, updateDog, deleteDog } = require('../controllers/dogs')
const { validateUserId, validateDogId } = require('../middleware/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/', validateUserId)
router.use('/:dogId', validateDogId)


//logs: /api/v1/dog/:userId/:dogId/logs
const logsRouter = require('./logs')
router.use('/:dogId/logs', logsRouter)

//reminders: /api/v1/dog/:userId/:dogId/reminders
const reminderRouter = require('./reminders')
router.use('/:dogId/reminders', reminderRouter)


// BASE PATH /api/v1/user/:userId/dogs/

//gets all dogs
router.get('/', getDogs)
//no body


//gets specific dog
router.get('/:dogId', getDogs)
//no body


//creates dog
router.post('/', createDog)
/* BODY:
{"dogName": "requiredString", 
"icon": optionalImage}
*/



//updates dog
router.put('/:dogId', updateDog)
/* BODY:
{"dogName": "optionalString", 
"icon": optionalImage}
NOTE: At least one item to update, from all the optionals, must be provided.
*/


//deletes dog
router.delete('/:dogId', deleteDog)
//no body

module.exports = router