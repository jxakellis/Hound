const crypto = require('crypto');
const { formatString, formatSHA256Hash, areAllDefined } = require('./formatObject');

const hash = async (str, sal) => {
  const string = formatSHA256Hash(str);
  const salt = formatString(sal);

  if (areAllDefined(string, salt) === false) {
    return undefined;
  }
  const hashHex = crypto.createHash('sha256').update(string + salt).digest('hex');
  return hashHex;
};

module.exports = { hash };
