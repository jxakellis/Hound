const mysql = require('mysql');
const databasePassword = require('./databasePassword')

const database = mysql.createConnection({
    host : 'localhost',
    user : 'admin',
    password : databasePassword,
    database :  'Hound'
});

database.connect((err) => {
    if (err){
        throw err;
    }
    console.log('MySql Connected...')
});

module.exports = database