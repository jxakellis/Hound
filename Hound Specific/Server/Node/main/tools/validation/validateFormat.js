/**
 * Takes a string. If the string provided passes the regex and length checks, it is a valid userEmail and the function returns true. Otherwise, function returns false.
 */
const formatEmail = (userEmail) => {
  // eslint-disable-next-line no-useless-escape, max-len
  const emailRegex = /^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$/;

  if (!userEmail) {
    return undefined;
  }
  // for our purposes all emails should be in the foo@bar.com format
  // shortest possible email is therefore x@y.zz (6 characters)
  else if (userEmail.length < 6 || userEmail.length > 254) {
    return undefined;
  }

  const valid = emailRegex.test(userEmail);
  if (!valid) {
    return undefined;
  }

  // Further checking of some things regex can't handle
  const parts = userEmail.split('@');
  if (parts[0].length > 64) {
    return undefined;
  }
  const domainParts = parts[1].split('.');
  if (domainParts.some((part) => part.length > 63)) {
    return undefined;
  }

  return userEmail.toLowerCase();
};

/**
 * Converts provided date into format needed for database. If any check fails, returns undefined. Otherwise, returns correctly formatted date.
 */
const formatDate = (string) => {
  if (string) {
    const modifiedDate = new Date(string);
    // if date is defined
    try {
      modifiedDate.toISOString().slice(0, 19).replace('T', ' ');
      // date in correct format
      return modifiedDate;
    }
    catch (error) {
      // unable to convert format; incorrect format
      return undefined;
    }
  }
  else {
    // date was not provided
    return undefined;
  }
};

/**
 * Converts the provided string into a boolean. "true", "1", or 1 retuns true; "false", "0", or 0 returns false; all other values return undefined
 * This is needed as Boolean("string") always converts to true unless the string provided is ""
 */
const formatBoolean = (string) => {
  if (string === true || string === 'true' || string === '1' || string === 1) {
    return true;
  }
  else if (string === false || string === 'false' || string === '0' || string === 0) {
    return false;
  }

  return undefined;
};

/**
 * Converts the provided string into a number.
 * Any finite number will successfully convert into a number.
 * This is needed as Number("foo") converts into NaN with type of number.
 * This result circumvents the typeof bar === 'undefined' logic as its type is number even though its value is null/NaN/undefined.
*/
const formatNumber = (string) => {
  // must convert string to number
  if (Number.isFinite(Number(string)) === true) {
    return Number(string);
  }

  return undefined;
};

const formatArray = (string) => {
  if (Array.isArray(string) === true) {
    return string;
  }
  return undefined;
};

/**
 * Takes single object or array of objects. If ALL objects provided are defined, returns true. Otherwise, returns false. Behaves the same as atLeastOneDefined for single object.
 */
const areAllDefined = (...args) => {
  // array
  if (Array.isArray(args) === true) {
    // checks to see all objects in array are defined
    for (let i = 0; i < args.length; i += 1) {
      if (typeof args[i] === 'undefined') {
        // single object in array is undefined so return false
        return false;
      }
    }
    // all items are defined
    return true;
  }
  // single object,  not array
  else if (typeof args === 'undefined') {
    // object not defined
    return false;
  }
  // object is defined
  return true;
};

/**
 * Take single object or array of objects. If at least one object provided is defined, returns true. Otherwise, returns false. Behaves the same as areAllDefined for single object.
 */
const atLeastOneDefined = (...args) => {
  // array
  if (Array.isArray(args) === true) {
    let isObjectDefined = false;
    // checks to see if at least one object in array is defined

    for (let i = 0; i < args.length; i += 1) {
      if (typeof args[i] !== 'undefined') {
        // single object in array is defined so we can break loop as we are only looking for one defined
        isObjectDefined = true;
        break;
      }
    }

    if (isObjectDefined === true) {
      return true;
    }

    return false;
  }
  // single object,  not array

  else if (typeof args === 'undefined') {
    // object not defined
    return false;
  }
  // object is defined
  return true;
};

module.exports = {
  areAllDefined, atLeastOneDefined, formatEmail, formatDate, formatBoolean, formatNumber, formatArray,
};
