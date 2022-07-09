class DatabaseError extends Error {
  constructor(code) {
    super('Database query failed');
    this.message = 'Database query failed';
    this.code = code;
    this.name = this.constructor.name;
  }

  get toJSON() {
    const json = { message: this.message, code: this.code, name: this.name };
    return json;
  }
}

/*
error.code
ER_NO_POOL_CONNECTION
ER_NO_POOL_TRANSACTION
*/

module.exports = { DatabaseError };
