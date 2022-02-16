
const bodyParser = require('body-parser')
const express = require('express');
const app = express()

const userRouter = require('./routes/user')

// parse form data
app.use((req, res, next) => {
    bodyParser.urlencoded({ extended: true })(req, res, (error) => {
        if (error) {
            return res.status(400).json({ message: "Invalid Body; Unable To Parse", error: error })
        }

        next()
    })
})
app.use(express.urlencoded({ extended: false }))

// parse json
app.use((req, res, next) => {
    bodyParser.json()(req, res, (error) => {
        if (error) {
            return res.status(400).json({ message: "Invalid Body; Unable To Parse", error: error })
        }

        next()
    })
})

//router for user requests

/*
/api/v1/user/:userId (OPT)
/api/v1/user/:userId/configuration
/api/v1/user/:userId/dogs/:dogId (OPT)
/api/v1/user/:userId/dogs/:dogId/logs/:logId (OPT)
/api/v1/user/:userId/dogs/:dogId/reminders/:reminderId (OPT)
*/


app.use('/api/v1/user', userRouter)

app.listen(5000, () => {
    console.log(`Listening on port 5000`)
})