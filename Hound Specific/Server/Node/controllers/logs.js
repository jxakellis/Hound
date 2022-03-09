const { queryPromise } = require('../utils/queryPromise');
const {
  formatDate, formatNumber, areAllDefined, atLeastOneDefined,
} = require('../utils/validateFormat');
const { queryLog, queryLogs } = require('./queryFor/queryForLogs');

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
      const result = await queryLog(req, logId);
      req.commitQueries(req);
      return res.status(200).json({ result });
    }
    catch (error) {
      req.rollbackQueries(req);
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
    }
  }
  else {
    try {
      const result = await queryLogs(req, dogId);

      if (result.length === 0) {
        // successful but empty array, not logs to return
        req.commitQueries(req);
        return res.status(204).json({ result: [] });
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
      return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.code });
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
    return res.status(400).json({ message: 'Invalid Body; date or logType missing' });
  }
  else if (logType === 'Custom' && !customTypeName) {
    // see if logType is being updated to custom and tell the user to provide customTypeName if so.
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" logType' });
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
    return res.status(400).json({ message: 'Invalid Parameters; Database query failed; Check date or logType format', error: error.code });
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
    return res.status(400).json({ message: 'Invalid Body; No date, note, or logType provided' });
  }
  else if (logType === 'Custom' && !customTypeName) {
    // proper stuff is defined, then check to see customTypeName provided
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Body; No customTypeName provided for "Custom" logType' });
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
    return res.status(400).json({ message: 'Invalid Body or Parameters; Database query failed; Check date or logType format', error: error.code });
  }
};

const delLog = require('../utils/delete').deleteLog;

const deleteLog = async (req, res) => {
  const logId = formatNumber(req.params.logId);

  try {
    await delLog(req, logId);
    req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  catch (error) {
    req.rollbackQueries(req);
    return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.code });
  }
};

module.exports = {
  getLogs, createLog, updateLog, deleteLog,
};
