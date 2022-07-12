const { ValidationError } = require('../../main/tools/general/errors');
const { areAllDefined } = require('../../main/tools/format/validateDefined');
const { databaseQuery } = require('../../main/tools/database/databaseQuery');
const { deleteAllLogsForDogId } = require('./deleteForLogs');
const { deleteAllRemindersForFamilyIdDogId } = require('./deleteForReminders');

/**
 *  Queries the database to delete a dog and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteDogForFamilyIdDogId = async (req, familyId, dogId) => {
  const dogLastModified = new Date();

  if (areAllDefined(req, familyId, dogId) === false) {
    throw new ValidationError('req, familyId, or dogId missing', global.constant.error.value.MISSING);
  }

  // delete all reminders
  await deleteAllRemindersForFamilyIdDogId(req, familyId, dogId);

  // deletes all logs
  await deleteAllLogsForDogId(req, dogId);

  // deletes dog
  await databaseQuery(
    req,
    'UPDATE dogs SET dogIsDeleted = 1, dogLastModified = ? WHERE dogId = ?',
    [dogLastModified, dogId],
  );
};

/**
 * Queries the database to delete all dog and everything nested under them. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteAllDogsForFamilyId = async (req, familyId) => {
  if (areAllDefined(req, familyId) === false) {
    throw new ValidationError('req or familyId missing', global.constant.error.value.MISSING);
  }

  // attempt to find all dogIds
  const dogIds = await databaseQuery(
    req,
    'SELECT dogId FROM dogs WHERE dogIsDeleted = 0 AND familyId = ? LIMIT 18446744073709551615',
    [familyId],
  );

  // delete all the dogs
  for (let i = 0; i < dogIds.length; i += 1) {
    await deleteDogForFamilyIdDogId(req, familyId, dogIds[i].dogId);
  }
};

module.exports = { deleteDogForFamilyIdDogId, deleteAllDogsForFamilyId };