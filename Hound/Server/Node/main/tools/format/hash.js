const crypto = require('crypto');
const { formatString, formatSHA256Hash } = require('./formatObject');
const { areAllDefined } = require('./validateDefined');

function hash(string, salt) {
  const castedString = formatSHA256Hash(string);
  const castedSalt = formatString(salt);

  if (areAllDefined(castedString, castedSalt) === false) {
    return undefined;
  }
  const hashHex = crypto.createHash('sha256').update(castedString + castedSalt).digest('hex');
  return hashHex;
}

module.exports = { hash };
