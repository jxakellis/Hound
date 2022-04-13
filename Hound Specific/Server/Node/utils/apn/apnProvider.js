const apn = require('apn');
const {
  keyId, teamId,
} = require('./apnSensitive');

/*
// use certificate.pem and key.pem
const options = {
  cert: `${__dirname}/certificate.pem`,
  key: `${__dirname}/key.pem`,
  production: false,
};
*/

// use key.p8, keyId, and teamId
const options = {
  token: {
    key: `${__dirname}/key.p8`,
    keyId,
    teamId,
  },
  production: false,
};

const apnProvider = new apn.Provider(options);

module.exports = { apnProvider };
