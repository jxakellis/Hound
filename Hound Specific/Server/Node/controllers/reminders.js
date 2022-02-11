const { queryPromise } = require('../middleware/queryPromise')
const { formatDate, formatBoolean } = require('../middleware/validateFormat')

const { createCountdownComponents, updateCountdownComponents } = require('./reminderComponents/countdown')
const { createWeeklyComponents, updateWeeklyComponents } = require('./reminderComponents/weekly')
const { createMonthlyComponents, updateMonthlyComponents } = require('./reminderComponents/monthly')
const { createOneTimeComponents, updateOneTimeComponents } = require('./reminderComponents/oneTime')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
*/


const getReminders = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const reminderId = Number(req.params.reminderId)

    //reminderId was provided
    if (reminderId) {
        try {
            //left joins dogReminders and component tables so that a reminder has all of its components attached
            //tables where the dogReminder isn't present (i.e. its timingStyle is different) will just append lots of null values to result
            let result = await queryPromise('SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId WHERE dogReminders.reminderId = ?',
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

            return res.status(200).json(result)

        } catch (error) {
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error })
        }
    }
    //no reminderId
    else {
        try {
            //get all reminders for the dogId, then left join to all reminder components table so each reminder has compoents attached
            let result = await queryPromise('SELECT *, dogReminders.reminderId as reminderId FROM dogReminders LEFT JOIN reminderCountdownComponents ON dogReminders.reminderId = reminderCountdownComponents.reminderId LEFT JOIN reminderWeeklyComponents ON dogReminders.reminderId = reminderWeeklyComponents.reminderId LEFT JOIN reminderMonthlyComponents ON dogReminders.reminderId = reminderMonthlyComponents.reminderId LEFT JOIN reminderOneTimeComponents ON dogReminders.reminderId = reminderOneTimeComponents.reminderId WHERE dogReminders.dogId = ?',
                [dogId])

            if (result.length === 0) {
                //successful but empty array, not reminders to return
                return res.status(204).json(result)
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
                return res.status(200).json(result)
            }




        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error })
        }
    }
}



const createReminder = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const enabled = formatBoolean(req.body.enabled)

    //check to see that necessary generic reminder componetns are present
    if (!reminderType || !timingStyle || !executionBasis || typeof enabled === 'undefined') {
        return res.status(400).json({ message: 'Invalid Body; reminderType, timingStyle, executionBasis, or enabled Missing ' })
    }
    //if the reminder is custom, then it needs its custom name
    else if (reminderType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" reminderType' })
    }

    //define out here so reminderId can be accessed in catch block to delete entries
    let reminderId = undefined

    try {

        //need to check timingStyle before querying because a partially correct timing style can have the query data added to the database but kick back a warning, we only want exact matches

        if (timingStyle === "countdown") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled])
                .then((result) => reminderId = Number(result.insertId))
            await createCountdownComponents(reminderId, req)
        }
        else if (timingStyle === "weekly") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled])
                .then((result) => reminderId = Number(result.insertId))
            await createWeeklyComponents(reminderId, req)
        }
        else if (timingStyle === "monthly") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled])
                .then((result) => reminderId = Number(result.insertId))
            await createMonthlyComponents(reminderId, req)
        }
        else if (timingStyle === "oneTime") {
            //first insert to main reminder table to get reminderId, then insert to other tables
            await queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled) VALUES (?, ?, ?, ?, ?, ?)',
                [dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled])
                .then((result) => reminderId = Number(result.insertId))
            await createOneTimeComponents(reminderId, req)
        }
        else {
            //nothing matched timingStyle
            return res.status(400).json({ message: "Invalid Body; timingStyle Invalid" })
        }
        //was able to successfully create components for a certain timing style
        return res.status(200).json({ message: "Success", reminderId: reminderId })

    } catch (error) {
        //something went wrong, delete anything that possibly got added
        if (reminderId) {
            delReminder(reminderId)
                .then((result) => res.status(400).json({ message: 'Invalid Body; Database Query Failed', error: error }))
                .catch((err) => res.status(400).json({ message: 'Invalid Body; Database Query Failed', error: error }))
        }
        else {
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed', error: error })
        }

    }
}

const updateReminder = async (req, res) => {

    //FIX ME, need to delete from other databases when reminder is switched

    const reminderId = Number(req.params.reminderId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const enabled = formatBoolean(req.body.enabled)

    if (!reminderId || !reminderType || !timingStyle || !executionBasis || typeof enabled === 'undefined') {
        return res.status(400).json({ message: 'Invalid Body; No reminderId Or reminderType Or timingStyle Or executionBasis Or enabled Provided' })
    }
    else if (reminderType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" reminderType' })
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
        if (timingStyle) {
            await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
        }
        if (executionBasis) {
            await queryPromise('UPDATE dogReminders SET executionBasis = ? WHERE reminderId = ?', [executionBasis, reminderId])
        }
        if (typeof enabled !== 'undefined') {
            await queryPromise('UPDATE dogReminders SET enabled = ? WHERE reminderId = ?', [enabled, reminderId])
        }

        //to do, update reminder components
        return res.status(200).json({ message: "Success" })
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed', error: error })
    }
}
const delReminder = require('../middleware/delete').deleteReminder

const deleteReminder = async (req, res) => {
    const reminderId = Number(req.params.reminderId)

    return delReminder(reminderId)
        .then((result) => res.status(200).json({ message: "Success" }))
        .catch((error) => res.status(400).json({ message: 'Invalid Syntax; Database Query Failed', error: error }))
}

module.exports = { getReminders, createReminder, updateReminder, deleteReminder }