const { databaseQuery } = require('../database/databaseQuery');
const { areAllDefined } = require('../format/validateDefined');

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

const familyCodeLength = 8;

// Makes a code for a family to use that consists of A-Z and 0-9
const generateFamilyCode = () => {
  let result = '';
  // O and 0 + L and I are all removed because they look similar
  const characters = 'ABCDEFGHJKMNPQRSTUVWXYZ123456789';
  const charactersLength = characters.length;
  for (let i = 0; i < familyCodeLength; i += 1) {
    result += characters.charAt(getRandomInt(charactersLength));
  }
  return result;
};

// Generate a verified unique code for a family to use that consists of A-Z and 0-9 (excludes I, L, O, and 0 due to how similar they look)
async function generateVerifiedFamilyCode(connection) {
  if (areAllDefined(connection) === false) {
    return undefined;
  }

  let uniqueFamilyCode;
  while (areAllDefined(uniqueFamilyCode) === false) {
    const potentialFamilyCode = generateFamilyCode();
    // Necessary to disable no-await-in-loop as we can't use Promise.all() for a while loop. We have a unknown amount of promises
    // eslint-disable-next-line no-await-in-loop
    const result = await databaseQuery(
      connection,
      'SELECT familyCode FROM families WHERE familyCode = ? LIMIT 1',
      [potentialFamilyCode],
    );
    // if the result's length is zero, that means there wasn't a match for the family code and the code is unique
    if (result.length === 0) {
      uniqueFamilyCode = potentialFamilyCode;
    }
  }
  return uniqueFamilyCode;
}

module.exports = { generateVerifiedFamilyCode };
