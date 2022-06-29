const express = require('express');

const router = express.Router({ mergeParams: true });

const { validateSubscription } = require('../main/tools/format/validateSubscription');

router.use('/', validateSubscription);

const {
  getDogs, createDog, updateDog, deleteDog,
} = require('../controllers/main/dogs');
const { validateDogId } = require('../main/tools/format/validateId');

// validation that params are formatted correctly and have adequate permissions
router.param('dogId', validateDogId);

// route to dogs
const logsRouter = require('./logs');

router.use('/:dogId/logs', logsRouter);

// route to reminders
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
Single: { dogInfo }
*/

// updates dog
router.put('/:dogId', updateDog);
/* BODY:
Single: { dogInfo }
*/

// deletes dog
router.delete('/:dogId', deleteDog);
// no body

module.exports = router;
