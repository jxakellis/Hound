//const express = require('express')
//const router = express.Router({ mergeParams: true })

//const { getConfiguration, updateConfiguration } = require('../controllers/configuration')


// BASE PATH /api/v1/:userId/configuration/

//gets configuration/settings for a given user
//router.get('/', getConfiguration)
// no body

//user cannot create a configuration independently, so no route. userConfiguration created when user is created.

//updates configuration/settings for a given user
//router.put('/', updateConfiguration)
/* BODY:
{"notificationAuthorized":"optionalBool",
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

//user cannot delete a configuration independently, so no route. userConfiguration is deleted when user is deleted.

//module.exports = router