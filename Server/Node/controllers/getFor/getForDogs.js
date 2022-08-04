const { ValidationError } = require('../../main/tools/general/errors');
const { databaseQuery } = require('../../main/tools/database/queryDatabase');
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
async function getDogForDogId(connection, dogId, lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs) {
  if (areAllDefined(connection, dogId) === false) {
    throw new ValidationError('connection or dogId missing', global.constant.error.value.MISSING);
  }

  const castedLastDogManagerSynchronization = formatDate(lastDogManagerSynchronization);

  // if the user provides a last sync, then we look for dogs that were modified after this last sync.
  // Therefore, only providing dogs that were modified and the local client is outdated on
  const dogs = areAllDefined(castedLastDogManagerSynchronization)
    ? await databaseQuery(
      connection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND dogId = ? LIMIT 1`,
      [castedLastDogManagerSynchronization, dogId],
    )
    : await databaseQuery(
      connection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogId = ? LIMIT 1`,
      [dogId],
    );

  // no need to do anything else as there are no dogs
  if (dogs.length === 0) {
    return dogs;
  }

  const castedIsRetrievingReminders = formatBoolean(isRetrievingReminders);
  const castedIsRetrievingLogs = formatBoolean(isRetrievingLogs);
  if (atLeastOneDefined(castedIsRetrievingReminders, castedIsRetrievingLogs) === false) {
    return dogs;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(castedIsRetrievingReminders) && castedIsRetrievingReminders) {
    let reminderPromises = [];
    // add all the reminders we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      reminderPromises.push(getAllRemindersForDogId(connection, dogs[i].dogId, castedLastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    reminderPromises = await Promise.all(reminderPromises);

    // since reminderPromises is 1:1 and index the same as dogs, we can take the resolved reminderPromises and assign to the dogs in the dogs array
    for (let i = 0; i < reminderPromises.length; i += 1) {
      dogs[i].reminders = reminderPromises[i];
    }
  }

  if (areAllDefined(castedIsRetrievingLogs) && castedIsRetrievingLogs) {
    let logPromises = [];
    // add all the logs we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      logPromises.push(getAllLogsForDogId(connection, dogs[i].dogId, castedLastDogManagerSynchronization));
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
async function getAllDogsForUserIdFamilyId(connection, userId, familyId, lastDogManagerSynchronization, isRetrievingReminders, isRetrievingLogs) {
  // userId part is optional until later
  if (areAllDefined(connection, familyId) === false) {
    throw new ValidationError('connection or familyId missing', global.constant.error.value.MISSING);
  }

  const castedLastDogManagerSynchronization = formatDate(lastDogManagerSynchronization);

  // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
  const dogs = areAllDefined(castedLastDogManagerSynchronization)
    ? await databaseQuery(
      connection,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND familyId = ? LIMIT 18446744073709551615`,
      [castedLastDogManagerSynchronization, familyId],
    )
    : await databaseQuery(
      connection,
      `SELECT ${dogsColumns} FROM dogs WHERE familyId = ? LIMIT 18446744073709551615`,
      [familyId],
    );

  // no need to do anything else as there are no dogs
  if (dogs.length === 0) {
    return dogs;
  }

  const castedIsRetrievingReminders = formatBoolean(isRetrievingReminders);
  const castedIsRetrievingLogs = formatBoolean(isRetrievingLogs);
  if (atLeastOneDefined(castedIsRetrievingReminders, castedIsRetrievingLogs) === false) {
    return dogs;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(castedIsRetrievingReminders) && castedIsRetrievingReminders) {
    let reminderPromises = [];
    // add all the reminders we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      reminderPromises.push(getAllRemindersForDogId(connection, dogs[i].dogId, castedLastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    reminderPromises = await Promise.all(reminderPromises);

    // since reminderPromises is 1:1 and index the same as dogs, we can take the resolved reminderPromises and assign to the dogs in the dogs array
    for (let i = 0; i < reminderPromises.length; i += 1) {
      dogs[i].reminders = reminderPromises[i];
    }
  }

  if (areAllDefined(castedIsRetrievingLogs) && castedIsRetrievingLogs) {
    let logPromises = [];
    // add all the logs we want to retrieving into an array, 1:1 corresponding to dogs
    for (let i = 0; i < dogs.length; i += 1) {
      logPromises.push(getAllLogsForDogId(connection, dogs[i].dogId, castedLastDogManagerSynchronization));
    }

    // resolve this array (or throw error for whole request if there is a problem)
    logPromises = await Promise.all(logPromises);

    // since logPromises is 1:1 and index the same as dogs, we can take the resolved logPromises and assign to the dogs in the dogs array
    for (let i = 0; i < logPromises.length; i += 1) {
      dogs[i].logs = logPromises[i];
    }
  }

  // If the user retrieved the most updated information from the dog (by getting reminders and logs and providing a lastSynchronization), we update
  if (areAllDefined(userId, castedLastDogManagerSynchronization, castedIsRetrievingReminders, castedIsRetrievingLogs) && castedIsRetrievingReminders && castedIsRetrievingLogs) {
    // This function is retrieving the all dogs for a given familyId.
    // If the user also specified to get reminders and logs, that means this query is retrieving the ENTIRE dog manager
    // Therefore, the user's lastDogManagerSynchronization should be saved as this counts as a dogManagerSyncronization
    await databaseQuery(
      connection,
      'UPDATE userConfiguration SET lastDogManagerSynchronization = ? WHERE userId = ?',
      [castedLastDogManagerSynchronization, userId],
    );
  }

  return dogs;
}

module.exports = { getDogForDogId, getAllDogsForUserIdFamilyId };
