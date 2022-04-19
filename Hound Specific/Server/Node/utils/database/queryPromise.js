const { formatArray, areAllDefined } = require('./validateFormat');

/**
 * Queries the predefined database connection with the given sqlString
 */
const queryPromise = (request, sqlString, sqlVariables = undefined) => new Promise((resolve, reject) => {
  const poolConnection = request.connection;
  const genericConnection = request;
  let connection;
  if (areAllDefined(poolConnection) === true) {
    connection = poolConnection;
  }
  else if (areAllDefined(genericConnection) === true) {
    connection = genericConnection;
  }
  else {
    reject(new Error('Undefined connection for query promise'));
  }
  const sqlVariablesArray = formatArray(sqlVariables);
  // need a database to query

  if (!sqlString) {
    reject(new Error('Undefined sqlString for queryPromise'));
  }
  else if (!sqlVariablesArray) {
    // no variables for sql statement provided; this is acceptable
    connection.query(
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
    connection.query(
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
