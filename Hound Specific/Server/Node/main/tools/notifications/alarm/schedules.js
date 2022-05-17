// for all scheduled items. Cannot create multiple seperate schedulers.
const schedule = require('node-schedule');
const eventEmitter = require('events').EventEmitter;

const { NUMBER_OF_SCHEDULED_JOBS_ALLOWED } = require('../../../server/constants');

eventEmitter.defaultMaxListeners = NUMBER_OF_SCHEDULED_JOBS_ALLOWED;

module.exports = {
  schedule,
};
