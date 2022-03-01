const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const bodyParser = require('body-parser');
const express = require('express');

const app = express();

// const { assignConnection } = require('./databaseConnection');
// const userRouter = require('./routes/user');

// parse form data

app.use((req, res, next) => {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json({ message: 'Invalid Body; Unable to parse', error: error.message });
    }

    return next();
  });
});
app.use(express.urlencoded({ extended: false }));

// parse json
app.use((req, res, next) => {
  bodyParser.json()(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json({ message: 'Invalid Body; Unable to parse', error: error.message });
    }

    return next();
  });
});

// router for user requests

/*
/api/v1/user/:userId (OPT)
/api/v1/user/:userId/dogs/:dogId (OPT)
/api/v1/user/:userId/dogs/:dogId/logs/:logId (OPT)
/api/v1/user/:userId/dogs/:dogId/reminders/:reminderId (OPT)
*/

app.get('/', (req, res) => res.status(200).json({ message: 'Success' }));

// app.use('/', assignConnection);

// app.use('/api/v1/user', userRouter);

// app.listen(5000, () => {
// console.log('Listening on port 5000');
// });

exports.api = functions.https.onRequest(app);
exports.helloWorld = functions.https.onRequest((req, res) => {
  res.status(200).json({ message: 'Hello' });
});
