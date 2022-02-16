const database = require('../databaseConnection')
const { queryPromise } = require('../middleware/queryPromise')
const { formatDate, formatBoolean } = require('../middleware/validateFormat')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
*/

const getConfiguration = async (req) => {

    const userId = Number(req.params.userId)

    try {
        const userConfiguration = await queryPromise('SELECT * FROM userConfiguration WHERE userId = ?',
            [userId])

        if (userConfiguration.length === 0) {
            //successful but empty array, no user to return
            return res.status(204).json(userConfiguration)
        }
        else {
            //array has item(s), meaning userConfiguration was found, successful!
            return res.status(200).json(userConfiguration)
        }
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error })
    }

}

const createConfiguration = async (userId, req) => {

    //not an independent route, invoked when making a user, therefore we throw any error to be caught there
    try {
        const notificationAuthorized = formatBoolean(req.body.notificationAuthorized)
        const notificationEnabled = formatBoolean(req.body.notificationEnabled)
        const loudNotifications = formatBoolean(req.body.loudNotifications)
        const showTerminationAlert = formatBoolean(req.body.showTerminationAlert)
        const followUp = formatBoolean(req.body.followUp)
        const followUpDelay = Number(req.body.followUpDelay)
        const paused = formatBoolean(req.body.paused)
        const compactView = formatBoolean(req.body.compactView)
        const darkModeStyle = req.body.darkModeStyle
        const snoozeLength = Number(req.body.snoozeLength)
        const notificationSound = req.body.notificationSound

        await queryPromise(
            'INSERT INTO userConfiguration(userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, paused, compactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
            [userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, paused, compactView, darkModeStyle, snoozeLength, notificationSound])
    } catch (error) {
        throw error
    }

    //return queryPromise(
    //'INSERT INTO userConfiguration(userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, paused, compactView, darkModeStyle, snoozeLength, notificationSound) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
    //[userId, notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, paused, compactView, darkModeStyle, snoozeLength, notificationSound]
    // ).then((result) => res.status(200).json({ message: "Success", dogId: result.insertId }))
    // .catch((error) => res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed', error: error }))


}

const updateConfiguration = async (req) => {

    const userId = Number(req.params.userId)
    const notificationAuthorized = formatBoolean(req.body.notificationAuthorized)
    const notificationEnabled = formatBoolean(req.body.notificationEnabled)
    const loudNotifications = formatBoolean(req.body.loudNotifications)
    const showTerminationAlert = formatBoolean(req.body.showTerminationAlert)
    const followUp = formatBoolean(req.body.followUp)
    const followUpDelay = Number(req.body.followUpDelay)
    const paused = formatBoolean(req.body.paused)
    const compactView = formatBoolean(req.body.compactView)
    const darkModeStyle = req.body.darkModeStyle
    const snoozeLength = Number(req.body.snoozeLength)
    const notificationSound = req.body.notificationSound

    if (typeof notificationAuthorized === 'undefined' && typeof notificationEnabled === 'undefined'
        && typeof loudNotifications === 'undefined' && typeof showTerminationAlert === 'undefined' && typeof followUp === 'undefined'
        && !followUpDelay && typeof paused === 'undefined' && typeof compactView === 'undefined'
        && !darkModeStyle && !snoozeLength && !notificationSound) {
        return res.status(400).json({ message: 'Invalid Body; No notificationAuthorized, notificationEnabled, loudNotifications, showTerminationAlert, followUp, followUpDelay, paused, compactView, darkModeStyle, snoozeLength, or notificationSound Provided' })
    }
    try {
        if (notificationAuthorized) {
            await queryPromise('UPDATE userConfiguration SET notificationAuthorized = ? WHERE userId = ?',
                [notificationAuthorized, userId])
        }
        if (notificationEnabled) {
            await queryPromise('UPDATE userConfiguration SET notificationEnabled = ? WHERE userId = ?',
                [notificationEnabled, userId])
        }
        if (loudNotifications) {
            await queryPromise('UPDATE userConfiguration SET loudNotifications = ? WHERE userId = ?',
                [loudNotifications, userId])
        }
        if (showTerminationAlert) {
            await queryPromise('UPDATE userConfiguration SET showTerminationAlert = ? WHERE userId = ?',
                [showTerminationAlert, userId])
        }
        if (followUp) {
            await queryPromise('UPDATE userConfiguration SET followUp = ? WHERE userId = ?',
                [followUp, userId])
        }
        if (followUpDelay) {
            await queryPromise('UPDATE userConfiguration SET followUpDelay = ? WHERE userId = ?',
                [followUpDelay, userId])
        }
        if (paused) {
            await queryPromise('UPDATE userConfiguration SET paused = ? WHERE userId = ?',
                [paused, userId])
        }
        if (compactView) {
            await queryPromise('UPDATE userConfiguration SET compactView = ? WHERE userId = ?',
                [compactView, userId])
        }
        if (darkModeStyle) {
            await queryPromise('UPDATE userConfiguration SET darkModeStyle = ? WHERE userId = ?',
                [darkModeStyle, userId])
        }
        if (snoozeLength) {
            await queryPromise('UPDATE userConfiguration SET snoozeLength = ? WHERE userId = ?',
                [snoozeLength, userId])
        }
        if (notificationSound) {
            await queryPromise('UPDATE userConfiguration SET notificationSound = ? WHERE userId = ?',
                [notificationSound, userId])
        }
        return res.status(200).json({ message: "Success" })

    } catch (error) {
        res.status(400).json({ message: 'Invalid Body; Database Query Failed', error: error })
    }

}


module.exports = { getConfiguration, createConfiguration, updateConfiguration }