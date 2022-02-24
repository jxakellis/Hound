//const database = require('../databaseConnection')

/**
 * Queries the predefined database connection with the given sqlString
 * @param {*} sqlString 
 * @param sqlVariables an optional array of objects to fill in placeholder values ('?') in sqlString
 * @returns 
 */
const queryPromise = (request, sqlString, sqlVariables = undefined) => {
    return new Promise((resolve, reject) => {
        const poolConnection = request.connection
        //need a database to query

        if (!poolConnection){
            reject('Undefined poolConnection for query promise')
        }
        else if (!sqlString) {
            reject('Undefined sqlString for queryPromise')
        }
        //no variables for sql statement provided; this is acceptable
        else if (!sqlVariables) {
            poolConnection.query(sqlString,
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
                poolConnection.query(sqlString,
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