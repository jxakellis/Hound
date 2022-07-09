class ParseError extends Error {
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
ER_NO_PARSE_FORM_DATA
ER_NO_PARSE_JSON
*/

module.exports = { ParseError };
