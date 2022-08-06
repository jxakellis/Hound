const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const {
  formatBoolean, formatDate,
} = require('../../main/tools/format/formatObject');
const { areAllDefined, atLeastOneDefined } = require('../../main/tools/format/validateDefined');
const { getAllLogsForDogId } = require('./getForLogs');
const { getAllRemindersForDogId } = require('./getForReminders');

// Select every column except for familyId, and dogLastModified (by not transmitting, increases network efficiency)
// familyId is already known, and dogLastModified has no use client-side
const dogsColumns = 'dogId, dogName, dogIsDeleted';

/**
 *  If the query is successful, returns the dog for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getDogForDogId(databaseConnection, dogId, forLastDogManagerSynchronization, forIsRetrievingReminders, forIsRetrievingLogs) {
  if (areAllDefined(databaseConnection, dogId) === false) {
    throw new ValidationError('databaseConnection or dogId missing', global.constant.error.value.MISSING);
  }

  const lastDogManagerSynchronization = formatDate(forLastDogManagerSynchronization);

  // if the user provides a last sync, then we look for dogs that were modified after this last sync.
  // Therefore, only providing dogs that were modified and the local client is outdated on
  const dogs = areAllDefined(lastDogManagerSynchronization)
    ? await databaseQuery(
      databaseConnection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND dogId = ? LIMIT 1`,
      [lastDogManagerSynchronization, dogId],
    )
    : await databaseQuery(
      databaseConnection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogId = ? LIMIT 1`,
      [dogId],
    );

  // no need to do anything else as there are no dogs
  if (dogs.length === 0) {
    return dogs;
  }

  const isRetrievingReminders = formatBoolean(forIsRetrievingReminders);
  const isRetrievingLogs = formatBoolean(forIsRetrievingLogs);
  if (atLeastOneDefined(isRetrievingReminders, isRetrievingLogs) === false) {
    return dogs;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(isRetrievingReminders) && isRetrievingReminders) {
    let reminderPromises = [];
    // add all the reminders we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      reminderPromises.push(getAllRemindersForDogId(databaseConnection, dogs[i].dogId, lastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    reminderPromises = await Promise.all(reminderPromises);

    // since reminderPromises is 1:1 and index the same as dogs, we can take the resolved reminderPromises and assign to the dogs in the dogs array
    for (let i = 0; i < reminderPromises.length; i += 1) {
      dogs[i].reminders = reminderPromises[i];
    }
  }

  if (areAllDefined(isRetrievingLogs) && isRetrievingLogs) {
    let logPromises = [];
    // add all the logs we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      logPromises.push(getAllLogsForDogId(databaseConnection, dogs[i].dogId, lastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    logPromises = await Promise.all(logPromises);

    // since logPromises is 1:1 and index the same as dogs, we can take the resolved logPromises and assign to the dogs in the dogs array
    for (let i = 0; i < logPromises.length; i += 1) {
      dogs[i].logs = logPromises[i];
    }
  }

  return dogs;
}

/**
 *  If the query is successful, returns an array of all the dogs for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
async function getAllDogsForUserIdFamilyId(databaseConnection, userId, familyId, forLastDogManagerSynchronization, forIsRetrievingReminders, forIsRetrievingLogs) {
  // userId part is optional until later
  if (areAllDefined(databaseConnection, familyId) === false) {
    throw new ValidationError('databaseConnection or familyId missing', global.constant.error.value.MISSING);
  }

  const lastDogManagerSynchronization = formatDate(forLastDogManagerSynchronization);

  // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
  const dogs = areAllDefined(lastDogManagerSynchronization)
    ? await databaseQuery(
      databaseConnection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND familyId = ? LIMIT 18446744073709551615`,
      [lastDogManagerSynchronization, familyId],
    )
    : await databaseQuery(
      databaseConnection,
      `SELECT ${dogsColumns} FROM dogs WHERE familyId = ? LIMIT 18446744073709551615`,
      [familyId],
    );

  // no need to do anything else as there are no dogs
  if (dogs.length === 0) {
    return dogs;
  }

  const isRetrievingReminders = formatBoolean(forIsRetrievingReminders);
  const isRetrievingLogs = formatBoolean(forIsRetrievingLogs);
  if (atLeastOneDefined(isRetrievingReminders, isRetrievingLogs) === false) {
    return dogs;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(isRetrievingReminders) && isRetrievingReminders) {
    let reminderPromises = [];
    // add all the reminders we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      reminderPromises.push(getAllRemindersForDogId(databaseConnection, dogs[i].dogId, lastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    reminderPromises = await Promise.all(reminderPromises);

    // since reminderPromises is 1:1 and index the same as dogs, we can take the resolved reminderPromises and assign to the dogs in the dogs array
    for (let i = 0; i < reminderPromises.length; i += 1) {
      dogs[i].reminders = reminderPromises[i];
    }
  }

  if (areAllDefined(isRetrievingLogs) && isRetrievingLogs) {
    let logPromises = [];
    // add all the logs we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      logPromises.push(getAllLogsForDogId(databaseConnection, dogs[i].dogId, lastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    logPromises = await Promise.all(logPromises);

    // since logPromises is 1:1 and index the same as dogs, we can take the resolved logPromises and assign to the dogs in the dogs array
    for (let i = 0; i < logPromises.length; i += 1) {
      dogs[i].logs = logPromises[i];
    }
  }

  // If the user retrieved the most updated information from the dog (by getting reminders and logs and providing a lastSynchronization), we update
  if (areAllDefined(userId, lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs) && isRetrievingReminders && isRetrievingLogs) {
    // This function is retrieving the all dogs for a given familyId.
    // If the user also specified to get reminders and logs, that means this query is retrieving the ENTIRE dog manager
    // Therefore, the user's lastDogManagerSynchronization should be saved as this counts as a dogManagerSyncronization
    await databaseQuery(
      databaseConnection,
      'UPDATE userConfiguration SET lastDogManagerSynchronization = ? WHERE userId = ?',
      [lastDogManagerSynchronization, userId],
    );
  }

  return dogs;
}

module.exports = { getDogForDogId, getAllDogsForUserIdFamilyId };
