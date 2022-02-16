const express = require('express')
const router = express.Router({ mergeParams: true })

const { getUser, createUser, updateUser, deleteUser } = require('../controllers/user')

const { validateUserId } = require('../middleware/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/:userId', validateUserId)

//dogs: /api/v1/user/:userId/dogs
const dogsRouter = require('./dogs')
router.use('/:userId/dogs', dogsRouter)

//configuration: /api/v1/user/:userId/configuration
//const configurationRouter = require('./configuration')
//router.use('/:userId/configuration', configurationRouter)


// BASE PATH /api/v1/user/

//user user with email and password then return information from users table
router.get('/', getUser)
/* BODY:
{"email":"foo@gmail.com"}
*/

//user user with userId and password then return information from users table
router.get('/:userId', getUser)
// no body


//creates user
router.post('/', createUser)
/* BODY:
{"email":"requiredEmail",
"firstName":"requiredString",
"lastName":"requiredString",
"notificationAuthorized":"requiredBool",
"notificationEnabled":"requiredBool",
"loudNotifications":"requiredBool",
"showTerminationAlert":"requiredBool",
"followUp":"requiredBool",
"followUpDelay":"requiredInt",
"paused":"requiredBool",
"compactView":"requiredBool",
"darkModeStyle":"requiredString",
"snoozeLength":"requiredInt",
"notificationSound":"requiredString"}
*/

//updates user
router.put('/:userId', updateUser)
/* BODY:
{"email":"optionalEmail",
"firstName":"optionalString",
"lastName":"optionalString",
"notificationAuthorized":"optionalBool",
"notificationEnabled":"optionalBool",
"loudNotifications":"optionalBool",
"showTerminationAlert":"optionalBool",
"followUp":"optionalBool",
"followUpDelay":"optionalInt",
"paused":"optionalBool",
"compactView":"optionalBool",
"darkModeStyle":"optionalString",
"snoozeLength":"optionalInt",
"notificationSound":"optionalString"}
NOTE: At least one item to update, from all the optionals, must be provided.
*/

//deletes user
router.delete('/:userId', deleteUser)
// no body

module.exports = router