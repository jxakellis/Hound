const { getLogForLogId, getAllLogsForDogId } = require('../getFor/getForLogs');
const { createLogForUserIdDogId } = require('../createFor/createForLogs');
const { updateLogForDogIdLogId } = require('../updateFor/updateForLogs');
const { deleteLogForLogId } = require('../deleteFor/deleteForLogs');
const { convertErrorToJSON } = require('../../main/tools/general/errors');
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
      ? await getLogForLogId(req, logId, lastDogManagerSynchronization)
    // query for multiple logs
      : await getAllLogsForDogId(req, dogId, lastDogManagerSynchronization);

    await req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function createLog(req, res) {
  try {
    const { userId, familyId, dogId } = req.params;
    const {
      logDate, logAction, logCustomActionName, logNote,
    } = req.body;
    const result = await createLogForUserIdDogId(req, userId, dogId, logDate, logAction, logCustomActionName, logNote);
    await req.commitQueries(req);
    createLogNotification(
      userId,
      familyId,
      dogId,
      logAction,
      logCustomActionName,
    );
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function updateLog(req, res) {
  try {
    const { dogId, logId } = req.params;
    const {
      logDate, logAction, logCustomActionName, logNote,
    } = req.body;
    await updateLogForDogIdLogId(req, dogId, logId, logDate, logAction, logCustomActionName, logNote);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

async function deleteLog(req, res) {
  try {
    const { dogId, logId } = req.params;
    await deleteLogForLogId(req, dogId, logId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
}

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
