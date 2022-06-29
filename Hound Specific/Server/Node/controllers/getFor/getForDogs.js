const DatabaseError = require('../../main/tools/errors/databaseError');
const ValidationError = require('../../main/tools/errors/validationError');
const { queryPromise } = require('../../main/tools/database/queryPromise');
const {
  formatBoolean, formatDate,
} = require('../../main/tools/format/formatObject');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { getAllLogsForDogId } = require('./getForLogs');
const { getAllRemindersForDogId } = require('./getForReminders');

// Select every column except for familyId, and dogLastModified (by not transmitting, increases network efficiency)
// familyId is already known, and dogLastModified has no use client-side
const dogsColumns = 'dogId, dogName, dogIsDeleted';

/**
 *  If the query is successful, returns the dog for the dogId.
 *  If a problem is encountered, creates and throws custom error
 */
const getDogForDogId = async (req, dogId) => {
  const lastDogManagerSynchronization = formatDate(req.query.lastDogManagerSynchronization);

  if (areAllDefined(req, dogId) === false) {
    throw new ValidationError('dogId missing', 'ER_VALUES_MISSING');
  }

  try {
    let result;
    // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
    if (areAllDefined(lastDogManagerSynchronization)) {
      // therefore, a log/remidner could be updated in a dog but the server won't send back the updated info (since this information is nested under the dog which we never process)
      result = await queryPromise(
        req,
        `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND dogId = ? LIMIT 1`,
        [lastDogManagerSynchronization, dogId],
      );
    }
    else {
      result = await queryPromise(
        req,
        `SELECT ${dogsColumns} FROM dogs WHERE dogId = ? LIMIT 1`,
        [dogId],
      );
    }

    // no need to do anything else as there are no dogs
    if (result.length === 0) {
      return result;
    }

    const shouldRetrieveReminders = formatBoolean(req.query.reminders);
    const shouldRetrieveLogs = formatBoolean(req.query.logs);
    // if the query parameter indicates that they want the logs and the reminders too, we add them
    if (areAllDefined(shouldRetrieveReminders) && shouldRetrieveReminders) {
      const remindersResult = await getAllRemindersForDogId(req, dogId);

      result[0].reminders = remindersResult;
    }
    if (areAllDefined(shouldRetrieveLogs) && shouldRetrieveLogs) {
      const logsResult = await getAllLogsForDogId(req, dogId);

      result[0].logs = logsResult;
    }
    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

/**
 *  If the query is successful, returns an array of all the dogs for the familyId.
 *  If a problem is encountered, creates and throws custom error
 */
const getAllDogsForFamilyId = async (req, familyId) => {
  const userId = req.params.userId;
  const lastDogManagerSynchronization = formatDate(req.query.lastDogManagerSynchronization);

  if (areAllDefined(familyId) === false) {
    throw new ValidationError('familyId missing', 'ER_VALUES_MISSING');
  }

  try {
    let result;
    // if the user provides a last sync, then we look for dogs that were modified after this last sync. Therefore, only providing dogs that were modified and the local client is outdated on
    if (areAllDefined(lastDogManagerSynchronization)) {
      // therefore, a log/remidner could be updated in a dog but the server won't send back the updated info (since this information is nested under the dog which we never process)
      result = await queryPromise(
        req,
        `SELECT ${dogsColumns} FROM dogs WHERE dogLastModified >= ? AND familyId = ? LIMIT 18446744073709551615`,
        [lastDogManagerSynchronization, familyId],
      );
    }
    else {
      result = await queryPromise(
        req,
        `SELECT ${dogsColumns} FROM dogs WHERE familyId = ? LIMIT 18446744073709551615`,
        [familyId],
      );
    }

    const shouldRetrieveReminders = formatBoolean(req.query.reminders);
    const shouldRetrieveLogs = formatBoolean(req.query.logs);
    // if the query parameter indicates that they want the logs and the reminders too, we add them.
    if (areAllDefined(shouldRetrieveReminders) && shouldRetrieveReminders) {
      for (let i = 0; i < result.length; i += 1) {
        const reminderResult = await getAllRemindersForDogId(req, result[i].dogId);
        result[i].reminders = reminderResult;
      }
    }
    if (areAllDefined(shouldRetrieveLogs) && shouldRetrieveLogs) {
      for (let i = 0; i < result.length; i += 1) {
        const logResult = await getAllLogsForDogId(req, result[i].dogId);
        result[i].logs = logResult;
      }
    }

    if (areAllDefined(lastDogManagerSynchronization, shouldRetrieveReminders, shouldRetrieveLogs) && shouldRetrieveReminders && shouldRetrieveLogs) {
    // This function is retrieving the all dogs for a given familyId.
    // If the user also specified to get reminders and logs, that means this query is retrieving the ENTIRE dog manager
    // Therefore, the user's lastDogManagerSynchronization should be saved as this counts as a dogManagerSyncronization
      await queryPromise(
        req,
        'UPDATE userConfiguration SET lastDogManagerSynchronization = ? WHERE userId = ?',
        [lastDogManagerSynchronization, userId],
      );
    }

    return result;
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
};

module.exports = { getDogForDogId, getAllDogsForFamilyId };
