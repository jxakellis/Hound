const express = require('express');

const router = express.Router({ mergeParams: true });

const ValidationError = require('../main/tools/errors/validationError');

const convertErrorToJSON = require('../main/tools/errors/errorFormat');
const { areAllDefined } = require('../main/tools/validation/validateFormat');
const { createTerminateNotification } = require('../main/tools/notifications/alert/createTerminateNotification');

// User has done some action that warrents us sending them a special notification
router.post('/:alertType', async (req, res) => {
  const alertType = req.params.alertType;
  if (areAllDefined(alertType) === false) {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(new ValidationError('No alert type provided', 'ER_VALUES_INVALID')));
  }
  // the user has terminated the app
  if (alertType === 'terminate') {
    createTerminateNotification(req.params.userId);
  }
  await req.commitQueries(req);
  return res.status(200).json({ result: '' });
});
// no body

module.exports = router;
