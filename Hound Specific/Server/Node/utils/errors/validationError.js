class ValidationError extends Error {
  constructor(message, code) {
    super(message);
    this.message = message;
    this.code = code;
    this.name = this.constructor.name;
  }

  get toJSON() {
    const json = { message: this.message, code: this.code, name: this.name };
    return json;
  }
}

/*
ER_VALUES_MISSING
ER_VALUES_INVALID
ER_VALUES_BLANK
ER_ID_MISSING
ER_ID_INVALID
ER_NO_VALUES_PROVIDED
ER_NOT_FOUND
*/

module.exports = ValidationError;
