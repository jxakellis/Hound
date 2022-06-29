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

/// MARK: - Subscription
// The amount of milliseconds that we allow a family's subscription to expire before we enforce restrictions
const SUBSCRIPTION_GRACE_PERIOD = (3 * 60 * 60 * 1000);

/// MARK: - Default subscription details
// Default subscription's product id
const DEFAULT_SUBSCRIPTION_PRODUCT_ID = 'com.jonathanxakellis.hound.default';
// Default subscription's name
const DEFAULT_SUBSCRIPTION_NAME = 'Single 🧍‍♂️';
// Default subscription's description
const DEFAULT_SUBSCRIPTION_DESCRIPTION = "Explore Hound's default subscription tier by yourself with up to two different dogs";
// Default subscription was never purchased
const DEFAULT_SUBSCRIPTION_PURCHASE_DATE = undefined;
// Default subscription can have one family member (the one who created the family)
const DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS = 1;
// Default subscription can have two dogs
const DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS = 2;
// Default subscription doesn't expire
const DEFAULT_SUBSCRIPTION_EXPIRATION = new Date('3000-01-01T00:00:00Z');

/// MARK: - Limit the number of items for a given object
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
  SUBSCRIPTION_GRACE_PERIOD,
  DEFAULT_SUBSCRIPTION_PRODUCT_ID,
  DEFAULT_SUBSCRIPTION_NAME,
  DEFAULT_SUBSCRIPTION_DESCRIPTION,
  DEFAULT_SUBSCRIPTION_PURCHASE_DATE,
  DEFAULT_SUBSCRIPTION_EXPIRATION,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
  NUMBER_OF_LOGS_PER_DOG,
  NUMBER_OF_REMINDERS_PER_DOG,
  REMINDER_CATEGORY,
  TERMINATE_CATEGORY,
  LOG_CATEGORY,
  GENERAL_CATEGORY,
};
