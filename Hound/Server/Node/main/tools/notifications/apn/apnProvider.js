const apn = require('apn');
const {
  keyId, teamId,
} = require('../../../secrets/apnIds');

// use key.p8, keyId, and teamId
const options = {
  token: {
    key: `${__dirname}/apnKey.p8`,
    keyId,
    teamId,
  },
  production: false,
};

const apnProvider = new apn.Provider(options);

module.exports = { apnProvider };
