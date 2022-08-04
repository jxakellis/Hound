const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { databaseQuery } = require('../../main/tools/database/queryDatabase');
const { deleteAllLogsForDogId } = require('./deleteForLogs');
const { deleteAllRemindersForFamilyIdDogId } = require('./deleteForReminders');

/**
 *  Queries the database to delete a dog and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
async function deleteDogForFamilyIdDogId(connection, familyId, dogId) {
  const dogLastModified = new Date();

  if (areAllDefined(connection, familyId, dogId) === false) {
    throw new ValidationError('connection, familyId, or dogId missing', global.constant.error.value.MISSING);
  }

  // delete all reminders
  await deleteAllRemindersForFamilyIdDogId(connection, familyId, dogId);

  // deletes all logs
  await deleteAllLogsForDogId(connection, dogId);

  // deletes dog
  await databaseQuery(
    connection,
    'UPDATE dogs SET dogIsDeleted = 1, dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
}

/**
 * Queries the database to delete all dog and everything nested under them. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
async function deleteAllDogsForFamilyId(connection, familyId) {
  if (areAllDefined(connection, familyId) === false) {
    throw new ValidationError('connection or familyId missing', global.constant.error.value.MISSING);
  }

  // attempt to find all dogIds
  const dogIds = await databaseQuery(
    connection,
    'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT 18446744073709551615',
    [familyId],
  );

  // delete all the dogs
  const promises = [];
  for (let i = 0; i < dogIds.length; i += 1) {
    promises.push(deleteDogForFamilyIdDogId(connection, familyId, dogIds[i].dogId));
  }
  await Promise.all(promises);
}

module.exports = { deleteDogForFamilyIdDogId, deleteAllDogsForFamilyId };
