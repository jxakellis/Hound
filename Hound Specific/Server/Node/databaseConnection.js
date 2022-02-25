const mysql = require('mysql')
const databasePassword = require('./databasePassword')

const pool = mysql.createPool({
    // Determines the pool's action when no connections are available and the limit has been reached. 
    //If true, the pool will queue the connection request and call it when one becomes available. 
    //If false, the pool will immediately call back with an error. 
    waitForConnections: true,
    //The maximum number of connection requests the pool will queue before returning an error from getConnection. 
    //If set to 0, there is no limit to the number of queued connection requests. 
    queueLimit: 0,
    //The maximum number of connections to create at once.
    connectionLimit: 10,
    host: 'localhost',
    user: 'admin',
    password: databasePassword,
    database: 'Hound'
})

pool.on('acquire', (connection) => {
    let date = new Date()
    console.log(`Connection ${connection.threadId} released at M:S:ms ${date.getMinutes()}:${date.getSeconds()}:${date.getMilliseconds()}`);
})

pool.on('release', (connection) => {
    let date = new Date()
    console.log(`Connection ${connection.threadId} released at M:S:ms ${date.getMinutes()}:${date.getSeconds()}:${date.getMilliseconds()}`);
});

const commitQueries = (req) => {
    req.connection.commit((error) => {
        if (error) {
            console.log(`Commit Query Error: ${error}`)
        }
    })
    req.connection.release()
}

const rollbackQueries = (req) => {
    req.connection.rollback((error) => {
        if (error) {
            console.log(`Rollback Query Error: ${error}`)
        }
    })
    req.connection.release()
}

const assignConnection = async (req, res, next) => {
    await pool.getConnection((err, connection) => {
        if (err) {
            //no need to release connection as there was a failing in actually creating connection 
            res.status(500).json({ message: "Couldn't create a pool connection" })
        }
        else {
            connection.beginTransaction((err) => {
                if (err) {
                    connection.release()
                    res.status(500).json({ message: "Couldn't begin a transaction with pool connection" })
                }
                else {
                    req.connection = connection
                    req.commitQueries = commitQueries
                    req.rollbackQueries = rollbackQueries
                    next()
                }
            })
        }
    })
}

module.exports = { assignConnection }

