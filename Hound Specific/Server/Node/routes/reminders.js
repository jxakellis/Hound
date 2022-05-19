const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getReminders, createReminder, updateReminder, deleteReminder,
} = require('../controllers/main/reminders');
const { validateParamsReminderId, validateBodyReminderId } = require('../main/tools/format/validateId');

// No need to validate body for get ( no body exists )
// No need to validate body for create ( there are no passed reminders )
// Validate body for put at specific route
// Validate body for delete at specific route

// validation that params are formatted correctly and have adequate permissions
router.param('reminderId', validateParamsReminderId);

// gets all reminders
router.get('/', getReminders);
// no body

// gets specific reminder
router.get('/:reminderId', getReminders);
// no body

// create reminder(s)
router.post('/', createReminder);
/* BODY:
Single: { reminderInfo }
Multiple: { reminders: [reminderInfo1, reminderInfo2...] }
*/

// update reminder(s)
router.put('/', validateBodyReminderId, updateReminder);
// router.put('/:reminderId', updateReminder);
/* BODY:
Single: { reminderInfo }
Multiple: { reminders: [reminderInfo1, reminderInfo2...] }
*/

// delete reminder(s)
router.delete('/', validateBodyReminderId, deleteReminder);
// router.delete('/:reminderId', deleteReminder);
/* BODY:
Single: { reminderId }
Multiple: { reminders: [reminderId1, reminderId2...] }
*/

module.exports = router;
