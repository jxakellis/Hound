const { queryPromise } = require('./queryPromise');

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

const familyCodeLength = 8;

// Makes a code for a family to use that consists of A-Z and 0-9
const generateFamilyCode = () => {
  let result = '';
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  const charactersLength = characters.length;
  for (let i = 0; i < familyCodeLength; i += 1) {
    result += characters.charAt(getRandomInt(charactersLength));
  }
  return result;
};

// Makes a verified unique code for a family to use that consists of A-Z and 0-9
// eslint-disable-next-line consistent-return
const generateVerifiedFamilyCode = async (req) => {
  let uniqueCodeGenerated = false;
  while (uniqueCodeGenerated === false) {
    const code = generateFamilyCode();
    const result = await queryPromise(
      req,
      'SELECT familyCode FROM families WHERE familyCode = ? LIMIT 1',
      [code],
    );
    // if the result's length is zero, that means there wasn't a match for the family code and the code is unique
    if (result.length === 0) {
      uniqueCodeGenerated = true;
      return code;
    }
  }
};

module.exports = { generateVerifiedFamilyCode };
