// If true, then when the server restarts we recreate all of the alarm notifications. If false, then assume dev environment and do nothing
const isProduction = false;

// The most recent build of the app published to the app store
const currentAppBuild = 4000;
// The second most recent build of the app, this will be the version most users are on until the app store one processes and they can update
const previousAppBuild = 3999;

// A user can have <= the number listed below of logs for each dog. E.g. if 100,000 then the family can have <= 100,000 logs per dog
const numberOfLogsPerDog = 100000;

// A user can have <= the number listed below of reminders for each dog. E.g. if 10 then the family can have <= 10 reminders per dog
const numberOfRemindersPerDog = 10;

module.exports = {
  isProduction, currentAppBuild, previousAppBuild, numberOfLogsPerDog, numberOfRemindersPerDog,
};
