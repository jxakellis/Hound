const DatabaseError = require('../../utils/errors/databaseError');
const ValidationError = require('../../utils/errors/validationError');
const { queryPromise } = require('../../utils/queryPromise');

/**
 * Returns the user for the userId. Errors not handled
 */
const getUserForUserIdQuery = async (req, userId) => {
  let userInformation;
  // only one user should exist for any userId otherwise the table is broken
  try {
    userInformation = await queryPromise(
      req,
      'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userId = ?',
      [userId],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }

  if (userInformation.length !== 1) {
    // successful but empty array, no user to return.
    // Theoretically could be multiple users found but that means the table is broken. Just do catch all
    throw new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND');
  }

  // array has item(s), meaning there was a user found, successful!
  return userInformation;
};

/**
 * Returns the user for the userIdentifier. Errors not handled
 */
const getUserForUserIdentifierQuery = async (req, userIdentifier) => {
// userIdentifier method of finding corresponding user(s)
  // userIdentifier already validated
  let userInformation;
  try {
    userInformation = await queryPromise(
      req,
      'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId LEFT JOIN familyMembers ON users.userId = familyMembers.userId WHERE users.userIdentifier = ?',
      [userIdentifier],
    );
  }
  catch (error) {
    throw new DatabaseError(error.code);
  }
  if (userInformation.length !== 1) {
    // successful but empty array, no user to return.
    // Theoretically could be multiple users found but that means the table is broken. Just do catch all
    throw new ValidationError('No user found or invalid permissions', 'ER_NOT_FOUND');
  }

  // array has item(s), meaning there was a user found, successful!
  return userInformation;
};

module.exports = { getUserForUserIdQuery, getUserForUserIdentifierQuery };
