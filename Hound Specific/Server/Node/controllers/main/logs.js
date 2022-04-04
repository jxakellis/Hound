const { formatNumber } = require('../../utils/validateFormat');

const { getLogQuery, getLogsQuery } = require('../getFor/getForLogs');
const { createLogQuery } = require('../createFor/createForLogs');
const { updateLogQuery } = require('../updateFor/updateForLogs');
const { deleteLogQuery } = require('../deleteFor/deleteForLogs');
const convertErrorToJSON = require('../../utils/errors/errorFormat');

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) logId formatted correctly and request has sufficient permissions to use
*/

const getLogs = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);
  const logId = formatNumber(req.params.logId);

  // if logId is defined and it is a number then continue
  if (logId) {
    try {
      const result = await getLogQuery(req, logId);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
  else {
    try {
      const result = await getLogsQuery(req, dogId);

      if (result.length === 0) {
        // successful but empty array, not logs to return
        req.commitQueries(req);
        return res.status(200).json({ result: [] });
      }
      else {
        // array has items, meaning there were logs found, successful!
        req.commitQueries(req);
        return res.status(200).json({ result });
      }
    }
    catch (error) {
      // error when trying to do query to database
      req.rollbackQueries(req);
      return res.status(400).json(convertErrorToJSON(error));
    }
  }
};

const createLog = async (req, res) => {
  try {
    const result = await createLogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const updateLog = async (req, res) => {
  try {
    await updateLogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

const deleteLog = async (req, res) => {
  try {
    await deleteLogQuery(req);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(error));
  }
};

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
