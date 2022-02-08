const express = require('express')
const router = express.Router({mergeParams: true})

const {getDogs, createDog, updateDog, deleteDog} = require('../controllers/dogs') 
const {validateUserId, validateDogId, validateDogNameFormat} = require('../middleware/validate')

//validation that params are formatted correctly and have adequate permissions
router.use('/:userId',validateUserId)
router.use('/:userId/:dogId', validateDogId)

//logs
const logsRouter = require('./logs')
router.use('/:userId/:dogId/logs', logsRouter)


// /api/v1/dog/...

//gets all dogs
router.get('/:userId',getDogs)
//gets specific dog
router.get('/:userId/:dogId',getDogs)

router.post('/:userId',validateDogNameFormat,createDog)
//{"dogName": "nameOfNewDog", "icon": iconOfNewDog}
//dogName required, icon optional

router.put('/:userId/:dogId',updateDog)
//{"dogName": "foo", "icon": foo}
//dogName optional, icon option, but AT LEAST ONE required

router.delete('/:userId/:dogId',deleteDog)

module.exports = router