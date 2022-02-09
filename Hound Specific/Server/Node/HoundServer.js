
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
/api/v1/:userId/configuration
/api/v1/:userId/dogs/:dogId (OPT)
/api/v1/:userId/dogs/:dogId/logs/:logId (OPT)
/api/v1/:userId/dogs/:dogId/reminders/:reminderId (OPT)
*/


app.use('/api/v1/login', loginRouter)
app.use('/api/v1/:userId/dogs', dogsRouter)

app.listen(5000, () => {
    console.log(`Listening on port 5000`)
})
