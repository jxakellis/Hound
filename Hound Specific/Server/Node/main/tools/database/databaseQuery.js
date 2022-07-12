const { ValidationError, DatabaseError } = require('../general/errors');
const { formatArray, formatString } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');

/**
 * Queries the predefined database connection with the given sqlString
 */
const databaseQuery = (potentialConnection, potentialSQLString, potentialSQLVariables = undefined) => new Promise((resolve, reject) => {
  const connection = areAllDefined(potentialConnection.connection) ? potentialConnection.connection : potentialConnection;

  if (areAllDefined(connection) === false) {
    reject(new ValidationError('Connection missing for databaseQuery', global.constant.error.value.MISSING));
  }

  const SQLString = formatString(potentialSQLString);

  if (areAllDefined(SQLString) === false) {
    reject(new ValidationError('SQLString missing for databaseQuery', global.constant.error.value.MISSING));
  }

  const SQLVariables = formatArray(potentialSQLVariables);

  if (areAllDefined(SQLVariables) === false) {
    // no variables for sql statement provided; this is acceptable
    connection.query(
      SQLString,
      (error, result) => {
        if (error) {
          // error when trying to do query to database
          reject(new DatabaseError(error.message, error.code));
        }
        else {
          // database queried successfully
          resolve(result);
        }
      },
    );
  }
  else {
    connection.query(
      SQLString,
      SQLVariables,
      (error, result) => {
        if (error) {
          // error when trying to do query to database
          reject(new DatabaseError(error.message, error.code));
        }
        else {
          // database queried successfully
          resolve(result);
        }
      },
    );
  }
});

module.exports = { databaseQuery };
