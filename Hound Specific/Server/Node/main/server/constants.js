const server = {
  SERVER_PORT: 3000,
  // If true, then when the server restarts we recreate all of the alarm notifications. Only output xxxLogger.error and serverLogger.* console messages
  // If false, then assume dev environment and output all xxxLogger.* console messages
  IS_PRODUCTION: false,
  // The most recent build of the app published to the app store
  CURRENT_APP_BUILD: 4000,
  // The second most recent build of the app, this will be the version most users are on until the app store one processes and they can update
  PREVIOUS_APP_BUILD: 3999,
};

const limit = {
  /// If we have too many jobs scheduled at once, it could slow performance.
  // Additionally, there could be uncaught jobs getting duplicated that won't get noticed with a high limit
  NUMBER_OF_SCHEDULED_JOBS_ALLOWED: 1000000,
  // A user can have <= the number listed below of logs for each dog. E.g. if 100,000 then the family can have <= 100,000 logs per dog
  NUMBER_OF_LOGS_PER_DOG: 50000,
  // A user can have <= the number listed below of reminders for each dog. E.g. if 10 then the family can have <= 10 reminders per dog
  NUMBER_OF_REMINDERS_PER_DOG: 10,
};

const apn = {
// for APN about reminder's alarms
  REMINDER_CATEGORY: 'reminder',
  // for APN telling the user that they terminated the Hound app accidentally (disabling their loud notifications)
  TERMINATE_CATEGORY: 'terminate',
  // for APN telling family that a user logged a certain reminder (i.e. took care of something for a dog)
  LOG_CATEGORY: 'log',
  // for APN just some generic alert, e.g. someone joined/left the family
  GENERAL_CATEGORY: 'generalAlert',
};

const subscription = {
  DEFAULT_SUBSCRIPTION_PRODUCT_ID: 'com.jonathanxakellis.hound.default',
  // The amount of milliseconds that we allow a family's subscription to expire before we enforce restrictions
  SUBSCRIPTION_GRACE_PERIOD: (3 * 60 * 60 * 1000),
  // The in app purchase offerings for subscriptions (default indicates free / no payment)
  SUBSCRIPTIONS: [
    {
      productId: 'com.jonathanxakellis.hound.default',
      subscriptionNumberOfFamilyMembers: 1,
      subscriptionNumberOfDogs: 2,
    },
    {
      productId: 'com.jonathanxakellis.hound.twofamilymemberstwodogs.monthly',
      subscriptionNumberOfFamilyMembers: 2,
      subscriptionNumberOfDogs: 2,
    },
    {
      productId: 'com.jonathanxakellis.hound.fourfamilymembersfourdogs.monthly',
      subscriptionNumberOfFamilyMembers: 4,
      subscriptionNumberOfDogs: 4,
    },
    {
      productId: 'com.jonathanxakellis.hound.sixfamilymemberssixdogs.monthly',
      subscriptionNumberOfFamilyMembers: 6,
      subscriptionNumberOfDogs: 6,
    },
    {
      productId: 'com.jonathanxakellis.hound.tenfamilymemberstendogs.monthly',
      subscriptionNumberOfFamilyMembers: 10,
      subscriptionNumberOfDogs: 10,
    },
  ],
};

global.constant = {
  server,
  limit,
  apn,
  subscription,
};

// Make sure that constants can't be modified
Object.freeze(global.constant);
