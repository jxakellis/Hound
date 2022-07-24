const server = {
  // If true, then when the server restarts we recreate all of the alarm notifications. Only output xxxLogger.error and serverLogger.* console messages
  // If false, then assume dev environment and output all xxxLogger.* console messages
  IS_PRODUCTION: false,
  SHOW_CONSOLE_MESSAGES: true,
  // App builds of the iOS Hound app that work properly with the server.
  // A version would be depreciated if an endpoint path is changed or endpoint data return format is changed
  COMPATIBLE_IOS_APP_BUILDS: [4000, 5000],
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
  length: {
    /*
      Tested different title & body length APN to see how much of the notification was displayed

      180 title & 0 body:     31 char title & 0 body
      0 title & 180 body:     0 char title & 128 char body
      180 title & 180 body:   31 char title & 128 char body
      29 title & 123 body:    29 char title & 123 char body
      30 title & 123 body:    30 char title & 123 char body
      29 title & 124 body:    29 char title & 124 char body
      30 title & 124 body:    30 char title & 124 char body
      31 title & 128 body:    31 char title & 128 char body
      32 title & 128 body:    32 char title & 128 char body

      NOTE: If the notification changes from showing 'now' next to it and shows '1m ago' (or similar),
      this increased text length (indicating time since notification arrived) can cause the title to be shortened (the time text expands)
      */
    ALERT_TITLE: 32,
    ALERT_BODY: 128,
  },
  category: {
    // for APN about reminder's alarms
    REMINDER: 'reminder',
    // for APN telling the user that they terminated the Hound app accidentally (disabling their loud notifications)
    TERMINATE: 'terminate',
    // for APN telling family that a user logged a certain reminder (i.e. took care of something for a dog)
    LOG: 'log',
    // for APN just some generic alert, e.g. someone joined/left the family
    GENERAL: 'general',
  },
};

const DEFAULT_SUBSCRIPTION_PRODUCT_ID = 'com.jonathanxakellis.hound.default';
const DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS = 1;
const DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS = 2;

const subscription = {
  DEFAULT_SUBSCRIPTION_PRODUCT_ID,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
  DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
  // The amount of milliseconds that we allow a family's subscription to expire before we enforce restrictions
  SUBSCRIPTION_GRACE_PERIOD: (0 * 60 * 60 * 1000),
  // The in app purchase offerings for subscriptions (default indicates free / no payment)
  SUBSCRIPTIONS: [
    {
      productId: DEFAULT_SUBSCRIPTION_PRODUCT_ID,
      subscriptionNumberOfFamilyMembers: DEFAULT_SUBSCRIPTION_NUMBER_OF_FAMILY_MEMBERS,
      subscriptionNumberOfDogs: DEFAULT_SUBSCRIPTION_NUMBER_OF_DOGS,
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

const error = {
/*
Category: ER_GENERAL                        PREVIOUS NAME (pre 7/9/2022)
ER_GENERAL_APP_BUILD_OUTDATED               (ER_APP_BUILD_OUTDATED)
ER_GENERAL_PARSE_FORM_DATA_FAILED           (ER_NO_PARSE_FORM_DATA)
ER_GENERAL_PARSE_JSON_FAILED                (ER_NO_PARSE_JSON)
ER_GENERAL_POOL_CONNECTION_FAILED           (ER_NO_POOL_CONNECTION)
ER_GENERAL_POOL_TRANSACTION_FAILED          (ER_NO_POOL_TRANSACTION)
ER_GENERAL_APPLE_SERVER_FAILED              (ER_APPLE_SERVER)

Category: ER_VALUE
ER_VALUE_MISSING                            (ER_VALUES_MISSING, ER_NO_VALUES_PROVIDED, ER_FAMILY_CODE_INVALID)
ER_VALUE_INVALID                            (ER_VALUES_INVALID, ER_NOT_FOUND, ER_ID_INVALID)

Category: ER_FAMILY
Sub-Category: LIMIT
ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW       (ER_FAMILY_MEMBER_LIMIT_TOO_LOW)
ER_FAMILY_LIMIT_DOG_TOO_LOW                 (ER_DOG_LIMIT_TOO_LOW)
ER_FAMILY_LIMIT_LOG_TOO_LOW                 (ER_LOGS_LIMIT_TOO_LOW)
ER_FAMILY_LIMIT_REMINDER_TOO_LOW            (ER_REMINDER_LIMIT_TOO_LOW)
ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED      (ER_FAMILY_MEMBER_LIMIT_EXCEEDED)
ER_FAMILY_LIMIT_DOG_EXCEEDED                (ER_DOG_LIMIT_EXCEEDED)

Sub-Category: JOIN
ER_FAMILY_JOIN_IN_FAMILY_ALREADY            (ER_FAMILY_ALREADY)
ER_FAMILY_JOIN_FAMILY_CODE_INVALID          (ER_FAMILY_NOT_FOUND)
ER_FAMILY_JOIN_FAMILY_LOCKED                (ER_FAMILY_LOCKED)

Sub-Category: PERMISSION
ER_FAMILY_PERMISSION_INVALID                (ER_FAMILY_PERMISSION_INVALID)
*/

  general: {
    APP_BUILD_OUTDATED: 'ER_GENERAL_APP_BUILD_OUTDATED',
    PARSE_FORM_DATA_FAILED: 'ER_GENERAL_PARSE_FORM_DATA_FAILED',
    PARSE_JSON_FAILED: 'ER_GENERAL_PARSE_JSON_FAILED',
    POOL_CONNECTION_FAILED: 'ER_GENERAL_POOL_CONNECTION_FAILED',
    POOL_TRANSACTION_FAILED: 'ER_GENERAL_POOL_TRANSACTION_FAILED',
    APPLE_SERVER_FAILED: 'ER_GENERAL_APPLE_SERVER_FAILED',
  },
  value: {
    MISSING: 'ER_VALUE_MISSING',
    INVALID: 'ER_VALUE_INVALID',
  },
  family: {
    limit: {
      FAMILY_MEMBER_TOO_LOW: 'ER_FAMILY_LIMIT_FAMILY_MEMBER_TOO_LOW',
      DOG_TOO_LOW: 'ER_FAMILY_LIMIT_DOG_TOO_LOW',
      LOG_TOO_LOW: 'ER_FAMILY_LIMIT_LOG_TOO_LOW',
      REMINDER_TOO_LOW: 'ER_FAMILY_LIMIT_REMINDER_TOO_LOW',
      FAMILY_MEMBER_EXCEEDED: 'ER_FAMILY_LIMIT_FAMILY_MEMBER_EXCEEDED',
      DOG_EXCEEDED: 'ER_FAMILY_LIMIT_DOG_EXCEEDED',
    },
    join: {
      FAMILY_CODE_INVALID: 'ER_FAMILY_JOIN_FAMILY_CODE_INVALID',
      FAMILY_LOCKED: 'ER_FAMILY_JOIN_FAMILY_LOCKED',
      IN_FAMILY_ALREADY: 'ER_FAMILY_JOIN_IN_FAMILY_ALREADY',
    },
    leave: {
      SUBSCRIPTION_ACTIVE: 'ER_FAMILY_LEAVE_SUBSCRIPTION_ACTIVE',
      INVALID: 'ER_FAMILY_LEAVE_INVALID',
    },
    permission: {
      INVALID: 'ER_FAMILY_PERMISSION_INVALID',
    },
  },
};

global.constant = {
  server,
  limit,
  apn,
  subscription,
  error,
};

// Make sure that constants can't be modified
Object.freeze(global.constant);
