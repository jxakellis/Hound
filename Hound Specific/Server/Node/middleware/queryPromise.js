const database = require('../databaseConnection')

const queryPromise = (sqlString, sqlVariables = undefined) => {
    return new Promise((resolve, reject) => {
        //need a database to query
        //if (!database) {
        //    reject('Undefined database for queryPromise')
        //}
        //need a sqlString to query
        if (!sqlString) {
            reject('Undefined sqlString for queryPromise')
        }
        //no variables for sql statement provided; this is acceptable
        else if (!sqlVariables) {
            database.query(sqlString,
                (error, result, fields) => {
                    if (error) {
                        //error when trying to do query to database
                        reject(error)
                    }
                    else {
                        //database queried successfully
                        resolve(result)
                    }
                }
            )
        }
        //variables for sql statement provided
        else {
            if (Array.isArray(sqlVariables) === false) {
                reject('sqlVariables must be array for queryPromise')
            }
            else {
                database.query(sqlString,
                    sqlVariables,
                    (error, result, fields) => {
                        if (error) {
                            //error when trying to do query to database
                            reject(error)
                        }
                        else {
                            //database queried successfully
                            resolve(result)
                        }
                    }
                )
            }
        }
    })
}

module.exports = { queryPromise }