// for regular notifications only; stores jobs under name Family123Reminder456, where 123 is familyId and 456 is reminderId
// const primarySchedule = require('node-schedule');
// for follow up notifications only; stores jobs under name User123Reminder456, where 123 is userId and 456 is reminderId
// const secondarySchedule = require('node-schedule');

// for all scheduled items. Cannot create multiple seperate schedulers.
const schedule = require('node-schedule');

// notification schedule uses a lot listeners, increase this limit as we scale
require('events').EventEmitter.defaultMaxListeners = 100;

module.exports = {
  schedule,
};
