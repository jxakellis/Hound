const { areAllDefined } = require('../format/formatObject');

const convertErrorToJSON = (error) => {
  // error isn't defined, so further reference would cause additional, uncaught error
  if (areAllDefined(error) === false) {
    return { message: 'Unknown Message', code: 'Unknown Code', name: 'UnknownError' };
  }
  // constructor isn't defined, so further reference would cause error
  else if (areAllDefined(error.constructor) === false) {
    return { message: error.message, code: error.code, name: 'UnknownError' };
  }
  else if (error.constructor.name === 'DatabaseError') {
    return error.toJSON;
  }
  else if (error.constructor.name === 'GeneralError') {
    return error.toJSON;
  }
  else if (error.constructor.name === 'ParseError') {
    return error.toJSON;
  }
  else if (error.constructor.name === 'ValidationError') {
    return error.toJSON;
  }
  else {
    return { message: error.message, code: error.code, name: error.constructor.name };
  }
};

module.exports = convertErrorToJSON;
