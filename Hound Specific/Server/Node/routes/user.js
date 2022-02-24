const express = require('express')
const router = express.Router({ mergeParams: true })

const { getUser, createUser, updateUser, deleteUser } = require('../controllers/user')

const { validateUserId } = require('../utils/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/:userId', validateUserId)

//dogs: /api/v1/user/:userId/dogs
const dogsRouter = require('./dogs')
router.use('/:userId/dogs', dogsRouter)


// BASE PATH /api/v1/user/...

//gets user with email then return information from users and userConfiguration table
router.get('/', getUser)
/* BODY:
{
"email":"requiredString"
}
*/

//gets user with userId then return information from users and userConfiguration table
router.get('/:userId', getUser)
// no body


//creates user and userConfiguration
router.post('/', createUser)
/* BODY:
{
"email":"requiredEmail",
"firstName":"requiredString",
"lastName":"requiredString",
"notificationAuthorized":"requiredBool",
"notificationEnabled":"requiredBool",
"loudNotifications":"requiredBool",
"showTerminationAlert":"requiredBool",
"followUp":"requiredBool",
"followUpDelay":"requiredInt",
"isPaused":"requiredBool",
"compactView":"requiredBool",
"darkModeStyle":"requiredString",
"snoozeLength":"requiredInt",
"notificationSound":"requiredString"
}
*/

//updates user
router.put('/:userId', updateUser)
/* BODY:

//At least one of the following must be defined: email, firstName, lastName, notificationAuthorized, notificationEnabled, 
        loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView,
        darkModeStyle, snoozeLength, or notificationSound

{
"email":"optionalEmail",
"firstName":"optionalString",
"lastName":"optionalString",
"notificationAuthorized":"optionalBool",
"notificationEnabled":"optionalBool",
"loudNotifications":"optionalBool",
"showTerminationAlert":"optionalBool",
"followUp":"optionalBool",
"followUpDelay":"optionalInt",
"isPaused":"optionalBool",
"compactView":"optionalBool",
"darkModeStyle":"optionalString",
"snoozeLength":"optionalInt",
"notificationSound":"optionalString"
}
*/

//deletes user
router.delete('/:userId', deleteUser)
// no body

module.exports = router