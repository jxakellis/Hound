const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getDogs, createDog, updateDog, deleteDog,
} = require('../controllers/main/dogs');
const { validateDogId } = require('../main/tools/validation/validateId');

// validation that params are formatted correctly and have adequate permissions
router.param('dogId', validateDogId);

const logsRouter = require('./logs');

router.use('/:dogId/logs', logsRouter);

const reminderRouter = require('./reminders');

router.use('/:dogId/reminders', reminderRouter);

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
