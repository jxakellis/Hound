const { queryPromise } = require('../../utils/queryPromise')
const { formatBoolean, formatNumber } = require('../../utils/validateFormat')

const createSnoozeComponents = async (reminderId, req) => {

    const isSnoozed = formatBoolean(req.body.isSnoozed)


    //Only insert components if the reminder is snoozing, otherwise there is no need for them
    //Errors intentionally uncaught so they are passed to invocation in reminders
    if (isSnoozed === true) {

        const executionInterval = formatNumber(req.body.snoozeExecutionInterval)
        const intervalElapsed = formatNumber(req.body.snoozeIntervalElapsed)
        await queryPromise('INSERT INTO reminderSnoozeComponents(reminderId, isSnoozed, executionInterval, intervalElapsed) VALUES (?,?,?,?)',
            [reminderId, isSnoozed, executionInterval, intervalElapsed])
    }
    else {
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',
            [reminderId])
    }
}
/**
 * Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
 * @param {*} reminderId 
 * @param {*} req 
 * @returns 
 */
const updateSnoozeComponents = async (reminderId, req) => {

    const isSnoozed = formatBoolean(req.body.isSnoozed)

    //if reminder is going into snooze mode then we update/insert the needed components
    if (isSnoozed === true) {

        const executionInterval = formatNumber(req.body.snoozeExecutionInterval)
        const intervalElapsed = formatNumber(req.body.snoozeIntervalElapsed)
        try {
            //If this succeeds: Reminder was not present in the snooze table and the reminder was snoozed. 
            //If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
            await queryPromise('INSERT INTO reminderSnoozeComponents(reminderId, isSnoozed, executionInterval, intervalElapsed) VALUES (?,?,?,?)',
                [reminderId, isSnoozed, executionInterval, intervalElapsed])
            return
        } catch (error) {

            //If this succeeds: Reminder was present in the snooze table, timingStyle didn't change, and the components were successfully updated
            //If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
            await queryPromise('UPDATE reminderSnoozeComponents SET isSnoozed = ?, executionInterval = ?, intervalElapsed = ? WHERE reminderId = ?',
                [isSnoozed, executionInterval, intervalElapsed, reminderId])
        }
    }
    //if the reminder is leaving snooze mode (isSnoozed === false) then we delete the components
    else {
        await queryPromise('DELETE FROM reminderSnoozeComponents WHERE reminderId = ?',
            [reminderId])
    }

}

module.exports = { createSnoozeComponents, updateSnoozeComponents }