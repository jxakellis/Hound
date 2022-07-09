class GeneralError extends Error {
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
ER_NOT_FOUND
*/

module.exports = { GeneralError };
