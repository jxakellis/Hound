const { getLogForLogId, getAllLogsForDogId } = require('../getFor/getForLogs');
const { createLogForUserIdDogId } = require('../createFor/createForLogs');
const { updateLogForDogIdLogId } = require('../updateFor/updateForLogs');
const { deleteLogForLogId } = require('../deleteFor/deleteForLogs');
const { createLogNotification } = require('../../main/tools/notifications/alert/createLogNotification');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) logId formatted correctly and request has sufficient permissions to use
*/
async function getLogs(req, res) {
  try {
    const { dogId, logId } = req.params;
    const { lastDogManagerSynchronization } = req.query;
    const result = areAllDefined(logId)
    // if logId is defined and it is a number then continue to find a single log
      ? await getLogForLogId(req.connection, logId, lastDogManagerSynchronization)
    // query for multiple logs
      : await getAllLogsForDogId(req.connection, dogId, lastDogManagerSynchronization);

    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function createLog(req, res) {
  try {
    const { userId, familyId, dogId } = req.params;
    const {
      logDate, logAction, logCustomActionName, logNote,
    } = req.body;
    const result = await createLogForUserIdDogId(req.connection, userId, dogId, logDate, logAction, logCustomActionName, logNote);
    createLogNotification(
      userId,
      familyId,
      dogId,
      logAction,
      logCustomActionName,
    );
    return res.sendResponseForStatusJSONError(200, { result }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function updateLog(req, res) {
  try {
    const { dogId, logId } = req.params;
    const {
      logDate, logAction, logCustomActionName, logNote,
    } = req.body;
    await updateLogForDogIdLogId(req.connection, dogId, logId, logDate, logAction, logCustomActionName, logNote);
    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

async function deleteLog(req, res) {
  try {
    const { dogId, logId } = req.params;
    await deleteLogForLogId(req.connection, dogId, logId);
    return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
  }
  catch (error) {
    return res.sendResponseForStatusJSONError(400, undefined, error);
  }
}

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
