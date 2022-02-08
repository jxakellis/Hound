
const bodyParser = require('body-parser')
const express = require('express');
const app = express()

const loginRouter = require('./routes/login')
const dogsRouter = require('./routes/dogs')

// parse form data
app.use((req, res, next) => {
    bodyParser.urlencoded({ extended: true })(req, res, err => {
        if (err) {
            return res.status(400).json({message:"Invalid Body; Unable To Parse"})
        }

        next()
    })
})
app.use(express.urlencoded({ extended: false }))

// parse json
app.use((req, res, next) => {
    bodyParser.json()(req, res, err => {
        if (err) {
            return res.status(400).json({message:"Invalid Body; Unable To Parse"})
        }

        next()
    })
})

//router for login requests

/*
/api/v1/login/:userId (OPT)
/api/v1/configuration/:userId
/api/v1/dogs/:userId/:dogId (OPT)
/api/v1/dogs/:userId/:dogId/logs/:logId (OPT)
/api/v1/dogs/:userId/:dogId/reminders/:reminderId (OPT)

To use path params from base path in nested router
https://stackoverflow.com/questions/28612822/node-js-get-url-params-from-original-base-url
router.get('/', function(req, res, next) {
  req.params.xyz = req.xyz;
});

*/


app.use('/api/v1/login', loginRouter)
app.use('/api/v1/dogs', dogsRouter)

app.listen(5000, () => {
    console.log(`Listening on port 5000`)
})
