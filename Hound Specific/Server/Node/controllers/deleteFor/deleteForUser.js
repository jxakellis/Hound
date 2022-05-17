// Purposefully disabled. There are lots of things to check for and it's a lot to make this process automatic.
// If a user wants to delete their account, then we can manually verify their account status, familyMember/familyHead state, and any dependencies
/**
 *  Queries the database to delete a user and everything nested under it. If the query is successful, then returns
 *  If an error is encountered, creates and throws custom error
 */
const deleteUserQuery = async () => '';
module.exports = { deleteUserQuery };
