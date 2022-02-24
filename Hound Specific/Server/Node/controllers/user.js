const database = require('../databaseConnection')
const { queryPromise } = require('../utils/queryPromise')
const { isEmailValid, areAllDefined, atLeastOneDefined, formatBoolean, formatDate, formatNumber } = require('../utils/validateFormat')

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {

    let email = req.body.email
    const userId = formatNumber(req.params.userId)

    //if the users provides an email and a userId then there is a problem. We don't know what to look for as those could be linked to different accounts
    if (email && userId) {
        return res.status(400).json({ message: "Invalid Parameters or Body; email and userId provided, only provide one." })
    }

    //userId method of finding corresponding user
    else if (userId) {
        //only one user should exist for any userId otherwise the table is broken
        try {
            const userInformation = await queryPromise('SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userId = ?',
                [userId])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                return res.status(204).json({message: 'Success', result: userInformation})
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                return res.status(200).json({message: 'Success', result: userInformation})
            }
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Parameters; user not found', error: error.message })
        }
    }
    //email method of finding corresponding user(s)
    else {

        if (isEmailValid(email) === false) {
            return res.status(400).json({ message: 'Invalid Body; email Invalid' })
        }
        //email valid, can convert to lower case without producing error
        email = req.body.email.toLowerCase()


        try {
            const userInformation = await queryPromise('SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userEmail = ?',
                [email.toLowerCase()])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                return res.status(204).json(userInformation)
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                return res.status(200).json(userInformation)
            }
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message })
        }
    }


}

const createUser = async (req, res) => {

    let email = req.body.email

    if (isEmailValid(email) === false) {
        //email NEEDs to be valid, so throw error if it is invalid
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
        return res.status(400).json({ message: 'Invalid Body; email, firstName, lastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound missing' })
    }
    else {
        let userId = undefined

        try {
            await queryPromise('INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
                [firstName, lastName, email])
                //everything worked
                .then((result) => userId = result.insertId)

            await queryPromise(
                'INSERT INTO userConfiguration(userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
                [userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, notificationSound])

            return res.status(200).json({ message: 'Success', userId: userId })
        } catch (errorOne) {
            //if something went wrong when creating the user configuration, then we must delete the user from both the users table and the user configuration table
            if (typeof userId !== 'undefined') {
                await delUser(userId)
                    .catch((errorTwo) => { return })
            }
            //something went wrong; the most likely option is that the email is a duplicate
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
        darkModeStyle, snoozeLength, notificationSound]) === false ){
        return res.status(400).json({ message: 'Invalid Body; No email, firstName, lastName, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, isPaused, compactView, darkModeStyle, snoozeLength, or notificationSound provided' })
    }
    else {
        try {
            if (areAllDefined(email)) {
                //email only needs to be valid if its provided, therefore check here

                if (isEmailValid(email) === false) {
                    return res.status(400).json({ message: 'Invalid Body; email Invalid' })
                }
                //email valid, can convert to lower case without producing error
                email = req.body.email.toLowerCase()

                await queryPromise('UPDATE users SET userEmail = ? WHERE userId = ?',
                    [email, userId])
            }
            if (areAllDefined(firstName)) {
                await queryPromise('UPDATE users SET userFirstName = ? WHERE userId = ?',
                    [firstName, userId])
            }
            if (areAllDefined(lastName)) {
                await queryPromise('UPDATE users SET userLastName = ? WHERE userId = ?',
                    [lastName, userId])
            }
            if (areAllDefined(notificationAuthorized)) {
                console.log("enter")
                await queryPromise('UPDATE userConfiguration SET notificationAuthorized = ? WHERE userId = ?',
                    [notificationAuthorized, userId]).then((result)=>console.log(result))
            }
            if (areAllDefined(notificationEnabled)) {
                await queryPromise('UPDATE userConfiguration SET notificationEnabled = ? WHERE userId = ?',
                    [notificationEnabled, userId])
            }
            if (areAllDefined(loudNotifications)) {
                await queryPromise('UPDATE userConfiguration SET loudNotifications = ? WHERE userId = ?',
                    [loudNotifications, userId])
            }
            if (areAllDefined(showTerminationAlert)) {
                await queryPromise('UPDATE userConfiguration SET showTerminationAlert = ? WHERE userId = ?',
                    [showTerminationAlert, userId])
            }
            if (areAllDefined(followUp)) {
                await queryPromise('UPDATE userConfiguration SET followUp = ? WHERE userId = ?',
                    [followUp, userId])
            }
            if (areAllDefined(followUpDelay)) {
                await queryPromise('UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
                    [followUpDelay, userId])
            }
            if (areAllDefined(isPaused)) {
                await queryPromise('UPDATE userConfiguration SET isPaused = ? WHERE userId = ?',
                    [isPaused, userId])
            }
            if (areAllDefined(compactView)) {
                await queryPromise('UPDATE userConfiguration SET compactView = ? WHERE userId = ?',
                    [compactView, userId])
            }
            if (areAllDefined(darkModeStyle)) {
                await queryPromise('UPDATE userConfiguration SET darkModeStyle = ? WHERE userId = ?',
                    [darkModeStyle, userId])
            }
            if (areAllDefined(snoozeLength)) {
                await queryPromise('UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
                    [snoozeLength, userId])
            }
            if (areAllDefined(notificationSound)) {
                await queryPromise('UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
                    [notificationSound, userId])
            }
            return res.status(200).json({ message: 'Success' })
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: error.message })
        }
    }


}

const delUser = require('../utils/delete').deleteUser

const deleteUser = async (req, res) => {

    const userId = formatNumber(req.params.userId)

    return delUser(userId)
        .then((result) => res.status(200).json({ message: 'Success' }))
        .catch((error) => res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.message }))
}


module.exports = { getUser, createUser, updateUser, deleteUser }