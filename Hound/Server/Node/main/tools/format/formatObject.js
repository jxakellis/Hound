const { areAllDefined } = require('./validateDefined');

/**
 * Takes a string. If the string provided passes the regex and length checks, it is a valid userEmail and the function returns true. Otherwise, function returns false.
 */
function formatEmail(string) {
  // eslint-disable-next-line no-useless-escape
  const emailRegex = /^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$/;
  const userEmail = formatString(string);
  if (areAllDefined(userEmail) === false) {
    return undefined;
  }
  // for our purposes all emails should be in the foo@bar.com format
  // shortest possible email is therefore x@y.zz (6 characters)
  if (userEmail.length < 6 || userEmail.length > 254) {
    return undefined;
  }

  const isValid = emailRegex.test(userEmail);
  if (isValid === false) {
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
}

/**
 * Converts provided date into format needed for database. If any check fails, returns undefined. Otherwise, returns correctly formatted date.
 */
function formatDate(date) {
  // check if parameter is defined
  if (areAllDefined(date) === false) {
    return undefined;
  }
  // parameter is a string, try to convert into a date
  if (typeof date === 'string') {
    const castedDate = new Date(date);

    // if not a date object or the date object is an invalid date (e.g. Date('nonDateFoo')), then we return undefined
    if (Object.prototype.toString.call(castedDate) !== '[object Date]' || Number.isNaN(castedDate) === true) {
      return undefined;
    }
    try {
      castedDate.toISOString().slice(0, 19).replace('T', ' ');
      // date in correct format
      return castedDate;
    }
    catch (error) {
      // unable to convert format; incorrect format
      return undefined;
    }
  }
  // if the date parameter is a date object and its date is valid (not 'Invalid Date'), then return
  else if (Object.prototype.toString.call(date) === '[object Date]' && Number.isNaN(date) === false) {
    return date;
  }
  // unrecognized type, return undefined
  else {
    return undefined;
  }
}

/**
 * Converts the provided string into a boolean. "true", "1", or 1 retuns true; "false", "0", or 0 returns false; all other values return undefined
 * This is needed as Boolean("string") always converts to true unless the string provided is ""
 */
function formatBoolean(boolean) {
  if (areAllDefined(boolean) === false) {
    return undefined;
  }
  if (typeof boolean === 'boolean') {
    // already a boolean object
    return boolean;
  }

  switch (boolean) {
    case 'true':
    case 1:
    case '1':
    case 'yes':
      return true;
    case 'false':
    case 0:
    case '0':
    case 'no':
      return false;
    default:
      return undefined;
  }
}

/**
 * Converts the provided string into a number.
 * Any finite number will successfully convert into a number.
 * This is needed as Number("foo") converts into NaN with type of number.
 * This result circumvents the typeof bar === 'undefined' logic as its type is number even though its value is null/NaN/undefined.
*/
function formatNumber(number) {
  if (areAllDefined(number) === false) {
    return undefined;
  }
  // forcible convert into a number. If it can't convert, then NaN is typically resolved
  const castedNumber = Number(number);

  /**
> Number.isFinite(1);
true
> Number.isFinite(1.0);
true
> Number.isFinite('foo');
false
> Number.isFinite(NaN);
false
> Number.isFinite(Infinity);
false
> Number.isFinite(null);
false
> Number.isFinite(undefined);
false
   */

  // if potentialNumber isn't finite, then we don't want it as a number.
  if (Number.isFinite(castedNumber) === false) {
    return undefined;
  }
  // potential number was cast and is finite, so its a number we can use
  return castedNumber;
}

function formatArray(array) {
  if (areAllDefined(array) === false) {
    return undefined;
  }
  if (Array.isArray(array) === false) {
    return undefined;
  }
  return array;
}

function formatSHA256Hash(string) {
  let castedString = formatString(string);
  if (areAllDefined(castedString) === false) {
    return undefined;
  }

  // OUTPUT IS CASE INSENSITIVE
  castedString = castedString.toLowerCase();

  const regex = /^[A-Fa-f0-9]{64}$/g;
  const isValid = regex.test(castedString);
  if (isValid === false) {
    return undefined;
  }
  return castedString;
}

function formatBase64EncodedString(string) {
  const castedString = formatString(string);
  if (areAllDefined(castedString) === false) {
    return undefined;
  }

  // OUTPUT IS CASE SENSITIVE
  const regex = /^(?:[A-Za-z\d+/]{4})*(?:[A-Za-z\d+/]{3}=|[A-Za-z\d+/]{2}==)?$/;
  const isValid = regex.test(castedString);
  if (isValid === false) {
    return undefined;
  }
  return castedString;
}

function formatString(string) {
  if (areAllDefined(string) === false) {
    return undefined;
  }

  if (typeof string !== 'string') {
    return undefined;
  }

  return string;
}

module.exports = {
  formatEmail, formatDate, formatBoolean, formatNumber, formatArray, formatSHA256Hash, formatBase64EncodedString, formatString,
};
