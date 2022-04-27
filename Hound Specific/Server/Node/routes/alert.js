const express = require('express');

const router = express.Router({ mergeParams: true });

const ValidationError = require('../utils/errors/validationError');

const convertErrorToJSON = require('../utils/errors/errorFormat');
const { areAllDefined } = require('../utils/database/validateFormat');
const { createTerminateNotification } = require('../utils/notification/alert/createTerminateNotification');

// BASE PATH /api/v1/user/:userId/alert...

// User has done some action that warrents us sending them a special notification
router.post('/:alertType', async (req, res) => {
  if (areAllDefined([req.params, req.params.alertType])) {
    // the user has terminated the app
    if (req.params.alertType === 'terminate') {
      createTerminateNotification(req.params.userId);
    }
    await req.commitQueries(req);
    return res.status(200).json({ result: '' });
  }
  else {
    await req.rollbackQueries(req);
    return res.status(400).json(convertErrorToJSON(new ValidationError('No alert type provided', 'ER_VALUES_INVALID')));
  }
});
// no body

module.exports = router;
