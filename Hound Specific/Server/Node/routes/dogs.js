const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getDogs, createDog, updateDog, deleteDog,
} = require('../controllers/main/dogs');
const { validateDogId } = require('../utils/database/validateId');

// validation that params are formatted correctly and have adequate permissions
router.use('/:dogId', validateDogId);

// logs: /api/v1/dog/:userId/:dogId/logs
const logsRouter = require('./logs');

router.use('/:dogId/logs', logsRouter);

// reminders: /api/v1/dog/:userId/:dogId/reminders
const reminderRouter = require('./reminders');

router.use('/:dogId/reminders', reminderRouter);

// BASE PATH /api/v1/user/:userId/dogs/

// gets all dogs, query parameter of ?all attaches the logs and the reminders to the dog
router.get('/', getDogs);
// no body

// gets specific dog, query parameter of ?all attaches the logs and the reminders to the dogs
router.get('/:dogId', getDogs);
// no body

// creates dog
router.post('/', createDog);
/* BODY:
{
 "dogName": "requiredString",
"dogIcon": optionalImage //dogIcon only provided if user adds a custom dogIcon, don't store default dogIcon.
}
*/

// updates dog
router.put('/:dogId', updateDog);
/* BODY:

//At least one of the following must be defined: dogName or dogIcon

{
"dogName": "optionalString",
"dogIcon": optionalImage
}
*/

// deletes dog
router.delete('/:dogId', deleteDog);
// no body

module.exports = router;
