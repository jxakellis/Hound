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
  const { logType } = req.body;
  const { customTypeName } = req.body;

  if (areAllDefined([logDate, logType]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('date or logType missing', 'ER_VALUES_MISSING').toJSON);
  }
  else if (logType === 'Custom' && !customTypeName) {
    // see if logType is being updated to custom and tell the user to provide customTypeName if so.
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No customTypeName provided for "Custom" logType', 'ER_VALUES_MISSING').toJSON);
  }

  try {
    const result = await queryPromise(
      req,
      'INSERT INTO dogLogs(dogId, date, note, logType, customTypeName) VALUES (?, ?, ?, ?, ?)',
      [dogId, logDate, note, logType, customTypeName],
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
  const { logType } = req.body;
  const { customTypeName } = req.body;

  // if all undefined, then there is nothing to update
  if (atLeastOneDefined([logDate, note, logType]) === false) {
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No date, note, or logType provided', 'ER_NO_VALUES_PROVIDED').toJSON);
  }
  else if (logType === 'Custom' && !customTypeName) {
    // proper stuff is defined, then check to see customTypeName provided
    req.rollbackQueries(req);
    return res.status(400).json(new ValidationError('No customTypeName provided for "Custom" logType', 'ER_VALUES_MISSING').toJSON);
  }

  try {
    if (logDate) {
      await queryPromise(req, 'UPDATE dogLogs SET date = ? WHERE logId = ?', [logDate, logId]);
    }
    if (note) {
      await queryPromise(req, 'UPDATE dogLogs SET note = ? WHERE logId = ?', [note, logId]);
    }
    if (logType) {
      await queryPromise(req, 'UPDATE dogLogs SET logType = ? WHERE logId = ?', [logType, logId]);
    }
    if (customTypeName) {
      await queryPromise(req, 'UPDATE dogLogs SET customTypeName = ? WHERE logId = ?', [customTypeName, logId]);
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
