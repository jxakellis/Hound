const express = require('express')
const router = express.Router()

const {getLogin, createLogin, updateLogin, deleteLogin} = require('../controllers/login') 

const {validateUserId} = require('../middleware/validate')

router.use('/:userId',validateUserId)

// FULL PATH /api/v1/login/...
/*
NOTE: Middleware to validate email could potentially work but will  complicate code. 
For GET and PUT requests, email is optional but must be valid if provided where as POST email must always be valid.
*/

//login user with email and password then return information from users table
router.get('/', getLogin)
// {"email":"foo@gmail.com"}

//login user with userId and password then return information from users table
router.get('/:userId',getLogin)

router.post('/',createLogin)
// {"email":"newFoo@gmail.com","firstName":"newFoo","lastName":"newFoo"}
// email required, firstName required, lastName required

router.put('/:userId',updateLogin)
// {"email":"newFoo@gmail.com","firstName":"newFoo","lastName":"newFoo"}
// email optional, firstName optional, lastName optional, but AT LEAST ONE required

router.delete('/:userId',deleteLogin)

module.exports = router