const express = require('express');

const serverToServerRouter = express.Router({ mergeParams: true });

serverToServerRouter.post('/', (req, res) => {
  const data = req.body;
  const plain = Buffer.from(data, 'base64').toString('utf8');
  console.log(plain);
  return res.sendResponseForStatusJSONError(200, { result: '' }, undefined);
});

module.exports = { serverToServerRouter };
