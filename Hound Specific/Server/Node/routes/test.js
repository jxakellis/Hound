const express = require('express')
const router = express.Router({mergeParams: true})

const {getTest} = require('../controllers/test') 

const logger = async (req,res,next) => {
    console.log('logger route')
    req.params.foo = req.foo
    console.log(req.params)
    console.log(req.foo)
    next()
}

router.get('/',[logger, getTest])

module.exports = router