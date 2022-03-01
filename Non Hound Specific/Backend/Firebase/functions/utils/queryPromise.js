// const database = require('../databaseConnection')

/**
 * Queries the predefined database connection with the given sqlString
 * @param {*} sqlString
 * @param sqlVariables an optional array of objects to fill in placeholder values ('?') in sqlString
 * @returns
 */
const queryPromise = (request, sqlString, sqlVariables = undefined) => new Promise((resolve, reject) => {
  const poolConnection = request.connection;
  // need a database to query

  if (!poolConnection) {
    reject(Error('Undefined poolConnection for query promise'));
  }
  else if (!sqlString) {
    reject(Error('Undefined sqlString for queryPromise'));
  }
  else if (!sqlVariables) {
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
  else if (Array.isArray(sqlVariables) === false) {
    // variables for sql statement provided but isn't array, needs to be in array fotmat
    reject(Error('sqlVariables must be array for queryPromise'));
  }
  else {
    poolConnection.query(
      sqlString,
      sqlVariables,
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
