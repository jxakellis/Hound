const { ValidationError, DatabaseError } = require('../general/errors');
const { formatArray, formatString } = require('../format/formatObject');
const { areAllDefined } = require('../format/validateDefined');
const { serverConnectionForGeneral } = require('./databaseConnections');

/**
 * Queries the database with the given sqlString. If a connection is provided, then uses that connection, otherwise uses the serverConnectionForGeneral
 */
const databaseQuery = (forConnection, forSQLString, forSQLVariables) => new Promise((resolve, reject) => {
  const connection = areAllDefined(forConnection) ? forConnection : serverConnectionForGeneral;
  if (areAllDefined(connection) === false) {
    reject(new ValidationError('Connection missing for databaseQuery', global.constant.error.value.MISSING));
  }

  const SQLString = formatString(forSQLString);

  if (areAllDefined(SQLString) === false) {
    reject(new ValidationError('SQLString missing for databaseQuery', global.constant.error.value.MISSING));
  }

  const SQLVariables = areAllDefined(forSQLVariables) ? formatArray(forSQLVariables) : [];

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
});

module.exports = { databaseQuery };
