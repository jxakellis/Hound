const express = require('express')
const router = express.Router()

const { getLogin, createLogin, updateLogin, deleteLogin } = require('../controllers/login')

const { validateUserId } = require('../middleware/validateId')

//validation that params are formatted correctly and have adequate permissions
router.use('/:userId', validateUserId)



// BASE PATH /api/v1/login/

//login user with email and password then return information from users table
router.get('/', getLogin)
/* BODY:
{"email":"foo@gmail.com"}
*/

//login user with userId and password then return information from users table
router.get('/:userId', getLogin)
// no body


//creates login
router.post('/', createLogin)
/* BODY:
{"email":"requiredEmail",
"firstName":"requiredString",
"lastName":"requiredString"}
*/

//updates login
router.put('/:userId', updateLogin)
/* BODY:
{"email":"optionalEmail",
"firstName":"optionalString",
"lastName":"optionalString"}
NOTE: At least one item to update, from all the optionals, must be provided.
*/

//deletes login
router.delete('/:userId', deleteLogin)
// no body

module.exports = router