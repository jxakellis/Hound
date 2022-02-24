const { queryPromise } = require('../utils/queryPromise')
const { formatDate, formatBoolean, formatNumber, areAllDefined, atLeastOneDefined } = require('../utils/validateFormat')

const { createCountdownComponents, updateCountdownComponents } = require('./reminderComponents/countdown')
const { createWeeklyComponents, updateWeeklyComponents } = require('./reminderComponents/weekly')
const { createMonthlyComponents, updateMonthlyComponents } = require('./reminderComponents/monthly')
const { createOneTimeComponents, updateOneTimeComponents } = require('./reminderComponents/oneTime')
const { createSnoozeComponents, updateSnoozeComponents } = require('./reminderComponents/snooze')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
*/


const getReminders = async (req, res) => {
    const dogId = formatNumber(req.params.dogId)
    const reminderId = formatNumber(req.params.reminderId)

    //reminderId was provided
    if (reminderId) {
        try {
            //left joins dogReminders and component tables so that a reminder has all of its components attached
            //tables where the dogReminder isn't present (i.e. its timingStyle is different) will just append lots of null values to result
            let result = await queryPromise('SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId WHERE dogReminders.reminderId = ?',
                [reminderId])

            //there will be only one result so just take first item in array
            result = result[0]

            //because of all the null values from left join, since only one component table (for the corresponding timingStyle) will have the reminder, we need to remve
            for (let [key, value] of Object.entries(result)) {
                //checks for null json values, if json value is null then removes the key
                if (value === null) {
                    delete result[key]
                }
            }

            return res.status(200).json({ message: 'Success', result: result })

        } catch (error) {
            return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.message })
        }
    }
    //no reminderId
    else {
        try {
            //get all reminders for the dogId, then left join to all reminder components table so each reminder has compoents attached
            let result = await queryPromise('SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId LEFT JOIN reminderSnoozeComponents ON dogReminders.reminderId = reminderSnoozeComponents.reminderId WHERE dogReminders.dogId = ?',
                [dogId])

            if (result.length === 0) {
                //successful but empty array, not reminders to return
                return res.status(204).json({ message: 'Success', result: result })
            }
            else {
                //iterate through all the reminders returned
                for (let i = 0; i < result.length; i++) {
                    //because of all the null values from left join, since only one component table (for the corresponding timingStyle) will have the reminder, we need to remve
                    for (let [key, value] of Object.entries(result[i])) {
                        //checks for null json values, if json value is null then removes the key
                        if (value === null) {
                            delete result[i][key]
                        }
                    }
                }

                //array has items, meaning there were reminders found, successful!
                return res.status(200).json({ message: 'Success', result: result })
            }




        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.message })
        }
    }
}



const createReminder = async (req, res) => {
    const dogId = formatNumber(req.params.dogId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const isEnabled = formatBoolean(req.body.isEnabled)

    //check to see that necessary generic reminder componetns are present
    if (areAllDefined([reminderType, customTypeName, timingStyle, executionBasis, isEnabled]) === false) {
        //>= 1 of the objects are undefined
        return res.status(400).json({ message: 'Invalid Body; reminderType, timingStyle, executionBasis, or isEnabled missing ' })
    }
    //if the reminder is custom, then it needs its custom name
    else if (reminderType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName provided for "Custom" reminderType' })
    }

    //define out here so reminderId can be accessed in catch block to delete entries
    let reminderId = undefined

    try {

        //need to check timingStyle before querying because a partially correct timing style can have the query data added to the database but kick back a warning, we only want exact matches

        //no need to check for snooze components as a newly created reminder cant be snoozed, it can only be updated to be snoozing
        if (timingStyle === "countdown") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled])
                .then((result) => reminderId = formatNumber(result.insertId))
            await createCountdownComponents(reminderId, req)
        }
        else if (timingStyle === "weekly") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled])
                .then((result) => reminderId = formatNumber(result.insertId))
            await createWeeklyComponents(reminderId, req)
        }
        else if (timingStyle === "monthly") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled])
                .then((result) => reminderId = formatNumber(result.insertId))
            await createMonthlyComponents(reminderId, req)
        }
        else if (timingStyle === "oneTime") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, isEnabled])
                .then((result) => reminderId = formatNumber(result.insertId))
            await createOneTimeComponents(reminderId, req)
        }
        else {
            //nothing matched timingStyle
            return res.status(400).json({ message: "Invalid Body; timingStyle Invalid" })
        }
        //was able to successfully create components for a certain timing style
        return res.status(200).json({ message: 'Success', reminderId: reminderId })

    } catch (errorOne) {
        //something went wrong, delete anything that possibly got added
        if (reminderId) {
            //in both cases, give the user errorOne. This is the error their request generated. errorTwo is internal.
            delReminder(reminderId)
                .then((result) => res.status(400).json({ message: 'Invalid Body; Database query failed', error: errorOne.message }))
                .catch((errorTwo) => res.status(400).json({ message: 'Invalid Body; Database query failed', error: errorOne.message }))
        }
        else {
            return res.status(400).json({ message: 'Invalid Body; Database query failed', error: errorOne.message })
        }

    }
}

const delLeftOverReminderComponents = require('../utils/delete').deleteLeftoverReminderComponents

const updateReminder = async (req, res) => {

    //FIX ME, if updating to a new timingStyle, need to create data instead of just updating. current implementation doesn't add data to a the new table for timingStyle so update queries go nowhere

    const reminderId = formatNumber(req.params.reminderId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const isEnabled = formatBoolean(req.body.isEnabled)
    const isSnoozed = formatBoolean(req.body.isSnoozed)

    if (atLeastOneDefined([reminderType, timingStyle, executionBasis, isEnabled, isSnoozed]) === false){
        return res.status(400).json({ message: 'Invalid Body; No reminderId, reminderType, timingStyle, executionBasis, isEnabled, or isSnoozed provided' })
    }
    else if (reminderType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName provided for "Custom" reminderType' })
    }

    try {
        if (reminderType) {
            if (reminderType === "Custom") {
                await queryPromise('UPDATE dogReminders SET reminderType = ?, customTypeName = ?  WHERE reminderId = ?', [reminderType, customTypeName, reminderId])
            }
            else {
                await queryPromise('UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId])
            }

        }

        if (executionBasis) {
            await queryPromise('UPDATE dogReminders SET executionBasis = ? WHERE reminderId = ?', [executionBasis, reminderId])
        }
        if (typeof isEnabled !== 'undefined') {
            await queryPromise('UPDATE dogReminders SET isEnabled = ? WHERE reminderId = ?', [isEnabled, reminderId])
        }
        //save me for second to last since I have a high chance of failing
        if (timingStyle) {

            if (timingStyle === "countdown") {
                //add new
                await updateCountdownComponents(reminderId, req)
                //switch reminder to new mode
                await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
                //delete old components since reminder is successfully switched to new mode
                await delLeftOverReminderComponents(reminderId, timingStyle)

            }
            else if (timingStyle === "weekly") {
                //add new
                await updateWeeklyComponents(reminderId, req)
                //switch reminder to new mode
                await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
                //delete old components since reminder is successfully switched to new mode
                await delLeftOverReminderComponents(reminderId, timingStyle)

            }
            else if (timingStyle === "monthly") {
                //add new
                await updateMonthlyComponents(reminderId, req)
                //switch reminder to new mode
                await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
                //delete old components since reminder is successfully switched to new mode
                await delLeftOverReminderComponents(reminderId, timingStyle)
            }
            else if (timingStyle === "oneTime") {
                //add new
                await updateOneTimeComponents(reminderId, req)
                //switch reminder to new mode
                await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
                //delete old components since reminder is successfully switched to new mode
                await delLeftOverReminderComponents(reminderId, timingStyle)
            }
            else {
                return res.status(400).json({ message: 'Invalid Body; timingStyle Invalid' })
            }

        }
        //do last since timingStyle will delete snooze components
        if (typeof isSnoozed !== 'undefined') {
            await updateSnoozeComponents(reminderId, req)
            //no need to invoke anything else as the snoozeComponents are self contained and the function handles deleting snoozeComponents if isSnoozed is changing to false
        }


        //to do, update reminder components
        return res.status(200).json({ message: 'Success' })
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database query failed', error: error.message })
    }
}
const delReminder = require('../utils/delete').deleteReminder

const deleteReminder = async (req, res) => {
    const reminderId = formatNumber(req.params.reminderId)

    return delReminder(reminderId)
        .then((result) => res.status(200).json({ message: 'Success' }))
        .catch((error) => res.status(400).json({ message: 'Invalid Syntax; Database query failed', error: error.message }))
}

module.exports = { getReminders, createReminder, updateReminder, deleteReminder }