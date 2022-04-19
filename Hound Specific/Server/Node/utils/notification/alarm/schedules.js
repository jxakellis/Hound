// for regular notifications only; stores jobs under name Family123Reminder456, where 123 is familyId and 456 is reminderId
const primarySchedule = require('node-schedule');
// for follow up notifications only; stores jobs under name User123Reminder456, where 123 is userId and 456 is reminderId
const secondarySchedule = require('node-schedule');

// TO DO review all edge cases
/*
User joins a family, ensure they get primary and secondary notifications
User leaves a family, ensure no more primary or secondary notifications

User updates isFollowUpEnabled, create or destroy secondary notifications
User updates followUpDelay, update secondary notifications

Dog is updated, primary and secondary notifications are updated to reflect new dogName
Dog is deleted, primary and secondary notifications are deleted

Reminder is created, primary and secondary notifications are created
Reminder is updated, primary and secondary notifications are updated
Reminder is deleted, primary and secondary notifications are deleted
*/

module.exports = {
  primarySchedule, secondarySchedule,
};
