const database = require('../databaseConnection')
const { queryPromise } = require('./queryPromise')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable ) dogId formatted correctly and request has sufficient permissions to use
- (if appliciable ) logId formatted correctly and request has sufficient permissions to use
*/

/**
 * Deletes a user from the users table and all other associated data from all other tables.
 * @param {*} userId 
 */
const deleteUser = async (userId) => {

    //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

    let dogIds = await queryPromise('SELECT dogId FROM dogs WHERE userId = ?', [userId])
        .catch((error) => dogIds = [])
    //deletes all dogs
    for (let i = 0; i < dogIds.length; i++) {
        await deleteDog(dogIds[i].dogId)
            .catch((error) => { return })
    }
    //delete userConfiguration
    await deleteUserConfiguration(userId)
        .catch((error) => { return })
    //deletes user
    await queryPromise('DELETE FROM users WHERE userId = ?', [userId])
        .catch((error) => { return })

    /*
    try {
        const dogIds = await queryPromise('SELECT dogId FROM dogs WHERE userId = ?', [userId])
        //deletes all dogs
        for (let i = 0; i < dogIds.length; i++) {
            await deleteDog(dogIds[i].dogId)
        }
        //delete userConfiguration
        await deleteUserConfiguration(userId)
        //deletes user
        await queryPromise('DELETE FROM users WHERE userId = ?', [userId])
    } catch (error) {
        throw error
    }
    
    */
}

/**
 * Deletes userConfiguration from the userConfiguration table 
 * @param {*} userId 
 */
const deleteUserConfiguration = async (userId) => {

     //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

    //deletes user config
    await queryPromise('DELETE FROM userConfiguration WHERE userId = ?', [userId])
        .catch((error) => { return })

    /*
    try {
        //deletes user config
        await queryPromise('DELETE FROM userConfiguration WHERE userId = ?', [userId])
    } catch (error) {
        throw error
    }
   
    */
}

/**
 * Deletes dog from dogs table, logs from dogLogs table, and invokes deleteReminder for all reminderIds to handle removing reminders
 * @param {*} dogId 
 */
const deleteDog = async (dogId) => {

     //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

        const reminderIds = await queryPromise('SELECT reminderId FROM dogReminders WHERE dogId = ?', [dogId])
        .catch((error)=>{return})
        //deletes all reminders
        for (let i = 0; i < reminderIds.length; i++) {
            await deleteReminder(reminderIds[i].reminderId)
            .catch((error)=>{return})
        }
        //deletes all logs
        await queryPromise('DELETE FROM dogLogs WHERE dogId = ?', [dogId])
        .catch((error)=>{return})
        //deletes dog
        await queryPromise('DELETE FROM dogs WHERE dogId = ?', [dogId])
        .catch((error)=>{return})

    /*
    try {
        const reminderIds = await queryPromise('SELECT reminderId FROM dogReminders WHERE dogId = ?', [dogId])
        //deletes all reminders
        for (let i = 0; i < reminderIds.length; i++) {
            await deleteReminder(reminderIds[i].reminderId)
        }
        //deletes all logs
        await queryPromise('DELETE FROM dogLogs WHERE dogId = ?', [dogId])
        //deletes dog
        await queryPromise('DELETE FROM dogs WHERE dogId = ?', [dogId])
    } catch (error) {
        throw error
    }
    */

}

/**
 * Deletes a log from dogLogs table
 * @param {*} logId 
 */
const deleteLog = async (logId) => {

     //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

        await queryPromise('DELETE FROM dogLogs WHERE logId = ?', [logId])
        .catch((error)=>{return})

    /*
    try {
        await queryPromise('DELETE FROM dogLogs WHERE logId = ?', [logId])
    } catch (error) {
        throw error
    }
    */

}

/**
 * Deletes a reminder from dogReminder table and any component that may exist for it in any component table
 * @param {*} reminderId 
 */
const deleteReminder = async (reminderId) => {

     //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

        //deletes all components
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        //deletes reminder
        await queryPromise('DELETE FROM dogReminders WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})

    /* 
    try {
        //deletes all components
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
        //deletes reminder
        await queryPromise('DELETE FROM dogReminders WHERE reminderId = ?', [reminderId])
    } catch (error) {
        throw error
    } 
    */


}


/**
 * If a reminder is updated, its timingStyle can be updated and switch between modes. 
* This means we make an entry into a new component table and this also means the components from the old timingStyle are left over in another table
* This remove the extraneous compoents
 * @param {*} reminderId 
 * @param {*} newTimingStyle 
 */
const deleteLeftoverReminderComponents = async (reminderId, newTimingStyle) => {

     //Don't do a try catch statement as we want as many delete statements to execute as possible. Use .catch() to ignore errors

    if (newTimingStyle === "countdown") {
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        //updated reminder can't be snoozed so delete. 
        //possible optimization here, since the reminder could be snoozed in the future we could just update isSnoozed to false instead of deleting the data
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})

    }
    else if (newTimingStyle === "weekly") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})

    }
    else if (newTimingStyle === "monthly") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
    }
    else if (newTimingStyle === "oneTime") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        .catch((error)=>{return})

    }
    else {
        throw Error("Invalid timingStyle")
    }

    /* if (newTimingStyle === "countdown") {
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        //updated reminder can't be snoozed so delete. 
        //possible optimization here, since the reminder could be snoozed in the future we could just update isSnoozed to false instead of deleting the data
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])

    }
    else if (newTimingStyle === "weekly") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])

    }
    else if (newTimingStyle === "monthly") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
    }
    else if (newTimingStyle === "oneTime") {
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])

    }
    else {
        throw Error("Invalid timingStyle")
    } */

}

module.exports = { deleteUser, deleteUserConfiguration, deleteDog, deleteLog, deleteReminder, deleteLeftoverReminderComponents }





