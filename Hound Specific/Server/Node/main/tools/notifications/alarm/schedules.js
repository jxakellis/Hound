// for all scheduled items. Cannot create multiple seperate schedulers.
const schedule = require('node-schedule');
const eventEmitter = require('events').EventEmitter;

const { numberOfScheduledJobsAllowed } = require('../../../server/constants');

eventEmitter.defaultMaxListeners = numberOfScheduledJobsAllowed;

module.exports = {
  schedule,
};
