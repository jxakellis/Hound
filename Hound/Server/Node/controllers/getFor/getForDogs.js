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
const getDogForDogId = async (req, dogId, lastDogManagerSynchronization, shouldRetrieveReminders, shouldRetrieveLogs) => {
  if (areAllDefined(req, dogId) === false) {
    throw new ValidationError('req or dogId missing', global.constant.error.value.MISSING);
  }

  const lastSynchronization = formatDate(lastDogManagerSynchronization);

  let result;
  // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
  if (areAllDefined(lastSynchronization)) {
    // therefore, a log/remidner could be updated in a dog but the server won't send back the updated info (since this information is nested under the dog which we never process)
    result = await databaseQuery(
      req,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND dogId = ? LIMIT 1`,
      [lastSynchronization, dogId],
    );
  }
  else {
    result = await databaseQuery(
      req,
      `SELECT ${dogsColumns} FROM dogs WHERE dogId = ? LIMIT 1`,
      [dogId],
    );
  }

  // no need to do anything else as there are no dogs
  if (result.length === 0) {
    return result;
  }

  const reminders = formatBoolean(shouldRetrieveReminders);
  const logs = formatBoolean(shouldRetrieveLogs);
  if (atLeastOneDefined(reminders, logs) === false) {
    return result;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(reminders) && reminders) {
    for (let i = 0; i < result.length; i += 1) {
      const reminderResult = await getAllRemindersForDogId(req, result[i].dogId);
      result[i].reminders = reminderResult;
    }
  }

  if (areAllDefined(logs) && logs) {
    for (let i = 0; i < result.length; i += 1) {
      const logResult = await getAllLogsForDogId(req, result[i].dogId);
      result[i].logs = logResult;
    }
  }

  return result;
};

/**
 *  If the query is successful, returns an array of all the dogs for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getAllDogsForUserIdFamilyId = async (req, userId, familyId, lastDogManagerSynchronization, shouldRetrieveReminders, shouldRetrieveLogs) => {
  // userId part is optional until later
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('req or familyId missing', global.constant.error.value.MISSING);
  }

  const lastSynchronization = formatDate(lastDogManagerSynchronization);

  let result;
  // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
  if (areAllDefined(lastSynchronization)) {
    // therefore, a log/remidner could be updated in a dog but the server won't send back the updated info (since this information is nested under the dog which we never process)
    result = await databaseQuery(
      req,
      `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND familyId = ? LIMIT 18446744073709551615`,
      [lastSynchronization, familyId],
    );
  }
  else {
    result = await databaseQuery(
      req,
      `SELECT ${dogsColumns} FROM dogs WHERE familyId = ? LIMIT 18446744073709551615`,
      [familyId],
    );
  }

  // no need to do anything else as there are no dogs
  if (result.length === 0) {
    return result;
  }

  const reminders = formatBoolean(shouldRetrieveReminders);
  const logs = formatBoolean(shouldRetrieveLogs);
  if (atLeastOneDefined(reminders, logs) === false) {
    return result;
  }

  // if the query parameter indicates that they want the logs and the reminders too, we add them.
  if (areAllDefined(reminders) && reminders) {
    for (let i = 0; i < result.length; i += 1) {
      const reminderResult = await getAllRemindersForDogId(req, result[i].dogId);
      result[i].reminders = reminderResult;
    }
  }

  if (areAllDefined(logs) && logs) {
    for (let i = 0; i < result.length; i += 1) {
      const logResult = await getAllLogsForDogId(req, result[i].dogId);
      result[i].logs = logResult;
    }
  }

  // If the user retrieved the most updated information from the dog (by getting reminders and logs and providing a lastSynchronization), we update
  if (areAllDefined(userId, lastSynchronization, reminders, logs) && reminders && logs) {
    // This function is retrieving the all dogs for a given familyId.
    // If the user also specified to get reminders and logs, that means this query is retrieving the ENTIRE dog manager
    // Therefore, the user's lastDogManagerSynchronization should be saved as this counts as a dogManagerSyncronization
    await databaseQuery(
      req,
      'UPDATE userConfiguration SET lastDogManagerSynchronization = ? WHERE userId = ?',
      [lastSynchronization, userId],
    );
  }

  return result;
};

module.exports = { getDogForDogId, getAllDogsForUserIdFamilyId };
