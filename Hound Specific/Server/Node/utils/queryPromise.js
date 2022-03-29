// const database = require('../databaseConnection')
const { formatArray } = require('./validateFormat');

/**
 * Queries the predefined database connection with the given sqlString
 * @param {*} sqlString
 * @param sqlVariables an optional array of objects to fill in placeholder values ('?') in sqlString
 * @returns
 */
const queryPromise = (request, sqlString, sqlVariables = undefined) => new Promise((resolve, reject) => {
  const poolConnection = request.connection;
  const sqlVariablesArray = formatArray(sqlVariables);
  // need a database to query

  if (!poolConnection) {
    reject(Error('Undefined poolConnection for query promise'));
  }
  else if (!sqlString) {
    reject(Error('Undefined sqlString for queryPromise'));
  }
  else if (!sqlVariablesArray) {
    // no variables for sql statement provided; this is acceptable

    poolConnection.query(
      sqlString,
      (error, result) => {
        if (error) {
          // error when trying to do query to database
          reject(error);
        }
        else {
          // database queried successfully
          resolve(result);
        }
      },
    );
  }
  else {
    poolConnection.query(
      sqlString,
      sqlVariablesArray,
      (error, result) => {
        if (error) {
          // error when trying to do query to database
          reject(error);
        }
        else {
          // database queried successfully
          resolve(result);
        }
      },
    );
  }
});

module.exports = { queryPromise };
