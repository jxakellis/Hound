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
        else if (!sqlVariables){
            database.query(sqlString,
                (err, result, fields) => {
                    if (err) {
                        //error when trying to do query to database
                        reject(err)
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
                    (err, result, fields) => {
                        if (err) {
                            //error when trying to do query to database
                            reject(err)
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