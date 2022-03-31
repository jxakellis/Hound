const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');

const { queryPromise } = require('../../utils/queryPromise');
const {
  formatDate, formatNumber, areAllDefined, atLeastOneDefined,
} = require('../../utils/validateFormat');
const { getLogQuery, getLogsQuery } = require('../getFor/getForLogs');

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
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
  else {
    try {
      const result = await getLogsQuery(req, dogId);

      if (result.length === 0) {
        // successful but empty array, not logs to return
        req.commitQueries(req);
        // return res.status(204).json({ result: [] });
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
      return res.status(400).json(new DatabaseError(error.code).toJSON);
    }
  }
};

const createLog = async (req, res) => {
  const dogId = formatNumber(req.params.dogId);
  const logDate = formatDate(req.body.date);
  const { note } = req.body;
  const { logAction } = req.body;
  const { customActionName } = req.body;

  if (areAllDefined([logDate, logAction]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('date or logAction missing', 'ER_VALUES_MISSING').toJSON);
  }
  else if (logAction === 'Custom' && !customActionName) {
    // see if logAction is being updated to custom and tell the user to provide customActionName if so.
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No customActionName provided for "Custom" logAction', 'ER_VALUES_MISSING').toJSON);
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(dogId, date, note, logAction, customActionName) VALUES (?, ?, ?, ?, ?)',
      [dogId, logDate, note, logAction, customActionName],
    );
    req.commitQueries(req);
    return res.status(200).json({ result: result.insertId });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const updateLog = async (req, res) => {
  const logId = formatNumber(req.params.logId);
  const logDate = formatDate(req.body.date);
  const { note } = req.body;
  const { logAction } = req.body;
  const { customActionName } = req.body;

  // if all undefined, then there is nothing to update
  if (atLeastOneDefined([logDate, note, logAction]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No date, note, or logAction provided', 'ER_NO_VALUES_PROVIDED').toJSON);
  }
  else if (logAction === 'Custom' && !customActionName) {
    // proper stuff is defined, then check to see customActionName provided
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No customActionName provided for "Custom" logAction', 'ER_VALUES_MISSING').toJSON);
  }

  try {
    if (logDate) {
      await queryPromise(req, 'UPDATE dogLogs SET date = ? WHERE logId = ?', [logDate, logId]);
    }
    if (note) {
      await queryPromise(req, 'UPDATE dogLogs SET note = ? WHERE logId = ?', [note, logId]);
    }
    if (logAction) {
      await queryPromise(req, 'UPDATE dogLogs SET logAction = ? WHERE logId = ?', [logAction, logId]);
    }
    if (customActionName) {
      await queryPromise(req, 'UPDATE dogLogs SET customActionName = ? WHERE logId = ?', [customActionName, logId]);
    }
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

const delLog = require('../../utils/delete').deleteLog;

const deleteLog = async (req, res) => {
  const logId = formatNumber(req.params.logId);

  try {
    await delLog(req, logId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json(new DatabaseError(error.code).toJSON);
  }
};

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
