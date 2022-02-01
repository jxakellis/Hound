const express = require('express')
const router = express.Router()

const {getDogs, createDog, updateDog, deleteDog} = require('../controllers/dogs') 
const {validateUserIdFormat, validateDogIdFormat} = require('../middleware/middleware')

router.use('/:userId',validateUserIdFormat)
router.use('/:userId/:dogId', validateDogIdFormat)

router.get('/:userId',getDogs)
router.post('/:userId',createDog)
router.put('/:userId/:dogId',updateDog)
router.delete('/:userId/:dogId',deleteDog)

module.exports = router