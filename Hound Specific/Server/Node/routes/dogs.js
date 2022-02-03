const express = require('express')
const router = express.Router()

const {getDogs, createDog, updateDog, deleteDog} = require('../controllers/dogs') 
const {validateUserId, validateDogId, validateDogNameFormat} = require('../middleware/validate')

router.use('/:userId',validateUserId)
router.use('/:userId/:dogId', validateDogId)

// /api/v1/dog/...

router.get('/:userId',getDogs)

router.post('/:userId',validateDogNameFormat,createDog)
//{"dogName": "nameOfNewDog", "icon": iconOfNewDog}
//dogName required, icon optional

router.put('/:userId/:dogId',updateDog)
//{"dogName": "foo", "icon": foo}
//dogName optional, icon option, but AT LEAST ONE required

router.delete('/:userId/:dogId',deleteDog)

module.exports = router