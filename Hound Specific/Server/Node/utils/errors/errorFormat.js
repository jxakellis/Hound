const convertErrorToJSON = (error) => {
  if (error.constructor.name === 'DatabaseError') {
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
