const database = require('../databaseConnection')
const { queryPromise } = require('../utils/queryPromise')
const { isEmailValid, areAllDefined, atLeastOneDefined, formatBoolean, formatNumber } = require('../utils/validateFormat')

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {

    let email = req.body.email
    const userId = formatNumber(req.params.userId)

    //if the users provides an email and a userId then there is a problem. We don't know what to look for as those could be linked to different accounts
    if (email && userId) {
        req.rollbackQueries(req)
        return res.status(400).json({ message: "Invalid Parameters or Body; email and userId provided, only provide one." })
    }

    //userId method of finding corresponding user
    else if (userId) {
        //only one user should exist for any userId otherwise the table is broken
        try {
            const userInformation = await queryPromise(req, 
                'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userId = ?',
                [userId])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                req.commitQueries(req)
                return res.status(204).json({ message: 'Success', result: userInformation })
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                req.commitQueries(req)
                return res.status(200).json({ message: 'Success', result: userInformation })
            }
        } catch (error) {
            req.rollbackQueries(req)
            return res.status(400).json({ message: 'Invalid Parameters; user not found', error: error.message })
        }
    }
    //email method of finding corresponding user(s)
    else {

        if (isEmailValid(email) === false) {
            req.rollbackQueries(req)
            return res.status(400).json({ message: 'Invalid Body; email Invalid' })
        }
        //email valid, can convert to lower case without producing error
        email = req.body.email.toLowerCase()


        try {
            const userInformation = await queryPromise(req, 
                'SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userEmail = ?',
                [email.toLowerCase()])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                req.commitQueries(req)
                return res.status(204).json(userInformation)
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                req.commitQueries(req)
                return res.status(200).json(userInformation)
            }
        } catch (error) {
            req.rollbackQueries(req)
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message })
        }
    }


}

const createUser = async (req, res) => {


    let email = req.body.email

    if (isEmailValid(email) === false) {
        //email NEEDs to be valid, so throw error if it is invalid
        req.rollbackQueries(req)
        return res.status(400).json({ message: 'Invalid Body; email Invalid' })
    }
    //email valid, can convert to lower case without producing error
    email = req.body.email.toLowerCase()

    const firstName = req.body.firstName
    const lastName = req.body.lastName
    const notificationAuthorized = formatBoolean(req.body.notificationAuthorized)
    const notificationEnabled = formatBoolean(req.body.notificationEnabled)
    const loudNotifications = formatBoolean(req.body.loudNotifications)
    const showTerminationAlert = formatBoolean(req.body.showTerminationAlert)
    const followUp = formatBoolean(req.body.followUp)
    const followUpDelay = formatNumber(req.body.followUpDelay)
    const isPaused = formatBoolean(req.body.isPaused)
    const compactView = formatBoolean(req.body.compactView)
    const darkModeStyle = req.body.darkModeStyle
    const snoozeLength = formatNumber(req.body.snoozeLength)
    const notificationSound = req.body.notificationSound

    //component of the body is missing or invalid
    if (areAllDefined(
        [email, firstName, lastName, notificationAuthorized, notificationEnabled,
            loudNotifications, showTerminationAlert, followUp, followUpDelay,
            isPaused, compactView, darkModeStyle, snoozeLength, notificationSound]) === false) {
        //>=1 of the items is undefined
        req.rollbackQueries(req)
        return res.status(400).json({ message: 'Invalid Body; email, firstName, lastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound missing' })
    }
    else {
        let userId = undefined

        try {
            await queryPromise(req,
                'INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
                [firstName, lastName, email])
                //everything worked
                .then((result) => userId = result.insertId)

            await queryPromise(req,
                'INSERT INTO userConfiguration(userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
                [userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound])

                req.commitQueries(req)
                return res.status(200).json({ message: 'Success', userId: userId })
            
        } catch (errorOne) {
            req.rollbackQueries(req)
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: errorOne.message })
        }
    }

}

const updateUser = async (req, res) => {

    const userId = formatNumber(req.params.userId)
    let email = req.body.email
    const firstName = req.body.firstName
    const lastName = req.body.lastName

    const notificationAuthorized = formatBoolean(req.body.notificationAuthorized)
    const notificationEnabled = formatBoolean(req.body.notificationEnabled)
    const loudNotifications = formatBoolean(req.body.loudNotifications)
    const showTerminationAlert = formatBoolean(req.body.showTerminationAlert)
    const followUp = formatBoolean(req.body.followUp)
    const followUpDelay = formatNumber(req.body.followUpDelay)
    const isPaused = formatBoolean(req.body.isPaused)
    const compactView = formatBoolean(req.body.compactView)
    const darkModeStyle = req.body.darkModeStyle
    const snoozeLength = formatNumber(req.body.snoozeLength)
    const notificationSound = req.body.notificationSound

    //checks to see that all needed components are provided
    if (atLeastOneDefined([email, firstName, lastName, notificationAuthorized, notificationEnabled,
        loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView,
        darkModeStyle, snoozeLength, notificationSound]) === false) {
            req.rollbackQueries(req)
        return res.status(400).json({ message: 'Invalid Body; No email, firstName, lastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound provided' })
    }
    else {
        try {
            if (areAllDefined(email)) {
                //email only needs to be valid if its provided, therefore check here

                if (isEmailValid(email) === false) {
                    req.rollbackQueries(req)
                    return res.status(400).json({ message: 'Invalid Body; email Invalid' })
                }
                //email valid, can convert to lower case without producing error
                email = req.body.email.toLowerCase()

                await queryPromise(req,
                    'UPDATE users SET userEmail = ? WHERE userId = ?',
                    [email, userId])
            }
            if (areAllDefined(firstName)) {
                await queryPromise(req,
                    'UPDATE users SET userFirstName = ? WHERE userId = ?',
                    [firstName, userId])
            }
            if (areAllDefined(lastName)) {
                await queryPromise(req,
                    'UPDATE users SET userLastName = ? WHERE userId = ?',
                    [lastName, userId])
            }
            if (areAllDefined(notificationAuthorized)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET notificationAuthorized = ? WHERE userId = ?',
                    [notificationAuthorized, userId])
            }
            if (areAllDefined(notificationEnabled)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET notificationEnabled = ? WHERE userId = ?',
                    [notificationEnabled, userId])
            }
            if (areAllDefined(loudNotifications)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET loudNotifications = ? WHERE userId = ?',
                    [loudNotifications, userId])
            }
            if (areAllDefined(showTerminationAlert)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET showTerminationAlert = ? WHERE userId = ?',
                    [showTerminationAlert, userId])
            }
            if (areAllDefined(followUp)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET followUp = ? WHERE userId = ?',
                    [followUp, userId])
            }
            if (areAllDefined(followUpDelay)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
                    [followUpDelay, userId])
            }
            if (areAllDefined(isPaused)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET isPaused = ? WHERE userId = ?',
                    [isPaused, userId])
            }
            if (areAllDefined(compactView)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET compactView = ? WHERE userId = ?',
                    [compactView, userId])
            }
            if (areAllDefined(darkModeStyle)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET darkModeStyle = ? WHERE userId = ?',
                    [darkModeStyle, userId])
            }
            if (areAllDefined(snoozeLength)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
                    [snoozeLength, userId])
            }
            if (areAllDefined(notificationSound)) {
                await queryPromise(req,
                    'UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
                    [notificationSound, userId])
            }
            req.commitQueries(req)
            return res.status(200).json({ message: 'Success' })
        } catch (error) {
            req.rollbackQueries(req)
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message })
        }
    }


}

const delUser = require('../utils/delete').deleteUser

const deleteUser = async (req, res) => {

    const userId = formatNumber(req.params.userId)

    try {
        await delUser(req, userId)
        req.commitQueries(req)
        return res.status(200).json({ message: 'Success' })
    } catch (error) {
        req.rollbackQueries(req)
        return res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.message })
    }
}


module.exports = { getUser, createUser, updateUser, deleteUser }