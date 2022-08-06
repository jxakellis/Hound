const databaseConnectionPingQuery = 'SELECT userId FROM users LIMIT 1';

/// Performs basic query on user table to establish if the databaseConnection is valid
async function testDatabaseConnection(forDatabaseConnection) {
  await forDatabaseConnection.promise().query(databaseConnectionPingQuery);
}

module.exports = {
  testDatabaseConnection,
};
