const { getLogForLogId, getAllLogsForDogId } = require('../getFor/getForLogs');
const { createLogForUserIdDogId } = require('../createFor/createForLogs');
const { updateLogForDogIdLogId } = require('../updateFor/updateForLogs');
const { deleteLogForLogId } = require('../deleteFor/deleteForLogs');
const { convertErrorToJSON } = require('../../main/tools/errors/errorFormat');
const { createLogNotification } = require('../../main/tools/notifications/alert/createLogNotification');
const { areAllDefined } = require('../../main/tools/format/validateDefined');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) logId formatted correctly and request has sufficient permissions to use
*/
const getLogs = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    const logId = req.params.logId;
    let result;
    // if logId is defined and it is a number then continue to find a single log
    if (areAllDefined(logId)) {
      result = await getLogForLogId(req, logId, req.query.lastDogManagerSynchronization);
    }
    // query for multiple logs
    else {
      result = await getAllLogsForDogId(req, dogId, req.query.lastDogManagerSynchronization);
    }

    if (result.length === 0) {
      // successful but empty array, not logs to return
      await req.commitQueries(req);
      return res.status(200).json({ result: [] });
    }
    else {
      // array has items, meaning there were logs found, successful!
      await req.commitQueries(req);
      return res.status(200).json({ result });
    }
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const createLog = async (req, res) => {
  try {
    const userId = req.params.userId;
    const dogId = req.params.dogId;
    const result = await createLogForUserIdDogId(req, userId, dogId);
    await req.commitQueries(req);
    createLogNotification(
      req.params.userId,
      req.params.familyId,
      req.params.dogId,
      req.body.logAction,
      req.body.logCustomActionName,
    );
    return res.status(200).json({ result });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateLog = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    const logId = req.params.logId;
    await updateLogForDogIdLogId(req, dogId, logId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteLog = async (req, res) => {
  try {
    const dogId = req.params.dogId;
    const logId = req.params.logId;
    await deleteLogForLogId(req, dogId, logId);
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
