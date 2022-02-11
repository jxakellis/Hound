const mysql = require('mysql');
const databasePassword = require('./databasePassword')

const database = mysql.createConnection({
    host: 'localhost',
    user: 'admin',
    password: databasePassword,
    database: 'Hound'
});

database.connect(error => {
    if (error) {
        throw error;
    }
    console.log('MySql Connected...')
});

module.exports = database