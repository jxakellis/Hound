const { areAllDefined } = require('./validateFormat');

const formatName = (string) => {
  if (typeof string !== 'string') {
    return undefined;
  }
  // removes whitespaces and newLines from beginning / end of string
  return string.trim();
};

const validateFullName = (userFirstName, userLastName) => {
  const trimmedFirstName = formatName(userFirstName);
  const trimmedLastName = formatName(userLastName);

  if ((areAllDefined(trimmedFirstName) === false || trimmedFirstName === '') && (areAllDefined(trimmedLastName) === false || trimmedLastName === '')) {
    return 'No Name';
  }
  // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
  else if (areAllDefined(trimmedFirstName) === false && trimmedFirstName === '') {
    // no first name but has last name
    return trimmedLastName;
  }
  else if (areAllDefined(trimmedLastName) === false && trimmedLastName === '') {
    // no last name but has first name
    return trimmedFirstName;
  }
  else {
    return `${trimmedFirstName} ${trimmedLastName}`;
  }
};

const validateAbreviatedFullName = (userFirstName, userLastName) => {
  const trimmedFirstName = formatName(userFirstName);
  const trimmedLastName = formatName(userLastName);

  if ((areAllDefined(trimmedFirstName) === false || trimmedFirstName === '') && (areAllDefined(trimmedLastName) === false || trimmedLastName === '')) {
    return 'No Name';
  }
  // we know one of OR both of the trimmedFirstName and trimmedLast name are != nil && != ""
  else if (areAllDefined(trimmedFirstName) === false && trimmedFirstName === '') {
    // no first name but has last name
    return trimmedLastName;
  }
  else if (areAllDefined(trimmedLastName) === false && trimmedLastName === '') {
    // no last name but has first name
    return trimmedFirstName;
  }
  else {
    return `${trimmedFirstName} ${trimmedLastName.charAt(0)}`;
  }
};

module.exports = { validateFullName, validateAbreviatedFullName };
