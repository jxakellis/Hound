const express = require('express');
const app = express()

const loginRouter = require('./routes/login')
const dogsRouter = require('./routes/dogs')

// parse form data
app.use(express.urlencoded({ extended: false }))
// parse json
app.use(express.json())

//router for login requests
app.use('/api/v1/login', loginRouter)
app.use('/api/v1/dogs', dogsRouter)

app.listen(5000, () => {
    console.log(`Listening on port 5000`)
})
