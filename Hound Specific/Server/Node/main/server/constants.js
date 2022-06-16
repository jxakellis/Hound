/// MARK: - Server Itself
const SERVER_PORT = 3000;
// If true, then when the server restarts we recreate all of the alarm notifications. Only output xxxLogger.error and serverLogger.* console messages
// If false, then assume dev environment and output all xxxLogger.* console messages
const IS_PRODUCTION = false;
/// If we have too many jobs scheduled at once, it could slow performance.
// Additionally, there could be uncaught jobs getting duplicated that won't get noticed with a high limit
const NUMBER_OF_SCHEDULED_JOBS_ALLOWED = 1000000;

/// MARK: - Concurrency
// The most recent build of the app published to the app store
const CURRENT_APP_BUILD = 4000;
// The second most recent build of the app, this will be the version most users are on until the app store one processes and they can update
const PREVIOUS_APP_BUILD = 3999;

/// MARK: - Limit the number of items for a given object
const DEFAULT_SUBSCRIPTION_TIER_ID = '3b518c5a274b5726ff7a19a3e5dcb84e8da21aa2f3523bfc1b40f74622602610';
// A user can have <= the number listed below of logs for each dog. E.g. if 100,000 then the family can have <= 100,000 logs per dog
const NUMBER_OF_LOGS_PER_DOG = 50000;
// A user can have <= the number listed below of reminders for each dog. E.g. if 10 then the family can have <= 10 reminders per dog
const NUMBER_OF_REMINDERS_PER_DOG = 10;

/// MARK: - APN Categories
// for APN about reminder's alarms
const REMINDER_CATEGORY = 'reminder';
// for APN telling the user that they terminated the Hound app accidentally (disabling their loud notifications)
const TERMINATE_CATEGORY = 'terminate';
// for APN telling family that a user logged a certain reminder (i.e. took care of something for a dog)
const LOG_CATEGORY = 'log';
// for APN just some generic alert, e.g. someone joined/left the family
const GENERAL_CATEGORY = 'generalAlert';

module.exports = {
  SERVER_PORT,
  IS_PRODUCTION,
  NUMBER_OF_SCHEDULED_JOBS_ALLOWED,
  CURRENT_APP_BUILD,
  PREVIOUS_APP_BUILD,
  DEFAULT_SUBSCRIPTION_TIER_ID,
  NUMBER_OF_LOGS_PER_DOG,
  NUMBER_OF_REMINDERS_PER_DOG,
  REMINDER_CATEGORY,
  TERMINATE_CATEGORY,
  LOG_CATEGORY,
  GENERAL_CATEGORY,
};
