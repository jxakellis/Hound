const database = require('../databaseConnection')
const { queryPromise } = require('./queryPromise')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable ) dogId formatted correctly and request has sufficient permissions to use
- (if appliciable ) logId formatted correctly and request has sufficient permissions to use
*/

const deleteUser = async (userId) => {
    try {

        const dogIds = await queryPromise('SELECT dogId FROM dogs WHERE userId = ?', [userId])
        //deletes all dogs
        for (let i = 0; i < dogIds.length; i++) {
            await deleteDog(dogIds[i].dogId)
        }
        //deletes user config
        await queryPromise('DELETE FROM userConfiguration WHERE userId = ?', [userId])
        //deletes user
        await queryPromise('DELETE FROM users WHERE userId = ?', [userId])
    } catch (error) {
        throw error
    }
}

const deleteDog = async (dogId) => {
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

}

const deleteLog = async (logId) => {
    try {
        await queryPromise('DELETE FROM dogLogs WHERE logId = ?', [logId])
    } catch (error) {
        throw error
    }

}

const deleteReminder = async (reminderId) => {
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


}

//If a reminder is updated, its timingStyle can be updated and switch between modes. 
//This means we make an entry into a new component table and this also means the components from the old timingStyle are left over in another table
//This remove the extraneous compoents
const deleteLeftoverReminderComponents = async (reminderId, newTimingStyle) => {
     if (newTimingStyle === "countdown"){
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        //updated reminder can't be snoozed so delete. 
        //possible optimization here, since the reminder could be snoozed in the future we could just update isSnoozed to false instead of deleting the data
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])

    }
    else if (newTimingStyle === "weekly"){
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])

    }
    else if (newTimingStyle === "monthly"){
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderOneTimeComponents WHERE reminderId = ?', [reminderId])
    }
    else if (newTimingStyle === "oneTime"){
        await queryPromise('DELETE FROM reminderCountdownComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderWeeklyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderMonthlyComponents WHERE reminderId = ?', [reminderId])
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?', [reminderId])

    }
    else {
        throw Error("Invalid timingStyle")
    }

}

module.exports = { deleteUser, deleteDog, deleteLog, deleteReminder, deleteLeftoverReminderComponents }





