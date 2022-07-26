const express = require('express');

const serverToServerRouter = express.Router({ mergeParams: true });

serverToServerRouter.post('/', (req, res) => {
  console.log(req.params, req.body, req.query);
  return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
});

module.exports = { serverToServerRouter };
