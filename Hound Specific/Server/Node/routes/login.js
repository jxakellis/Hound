const express = require('express')
const router = express.Router()

const {getLogin, createLogin, updateLogin, deleteLogin} = require('../controllers/login') 

router.get('/',getLogin)
router.post('/',createLogin)
router.put('/:userId',updateLogin)
router.delete('/:userId',deleteLogin)

module.exports = router