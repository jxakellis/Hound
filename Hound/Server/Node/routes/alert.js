const express = require('express');

const alertRouter = express.Router({ mergeParams: true });

const { ValidationError, convertErrorToJSON } = require('../main/tools/general/errors');
const { areAllDefined } = require('../main/tools/format/validateDefined');
const { createTerminateNotification } = require('../main/tools/notifications/alert/createTerminateNotification');

// User has done some action that warrents us sending them a special notification
alertRouter.post('/:alertType', async (req, res) => {
  const alertType = req.params.alertType;
  if (areAllDefined(alertType) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(new ValidationError('No alert type provided', global.constant.error.value.INVALID)));
  }
  // the user has terminated the app
  if (alertType === global.constant.apn.TERMINATE_CATEGORY) {
    createTerminateNotification(req.params.userId);
  }
  await req.commitQueries(req);
  return res.status(200).json({ result: '' });
});
// no body

module.exports = { alertRouter };
