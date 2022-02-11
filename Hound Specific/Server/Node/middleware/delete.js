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

module.exports = { deleteUser, deleteDog, deleteLog, deleteReminder }





