const { queryPromise } = require('../../middleware/queryPromise')

/* KNOWN:
- reminderId defined
*/

const createCountdownComponents = async (reminderId, req) => {
    const executionInterval = Number(req.body.executionInterval)
    const intervalElapsed = Number(req.body.intervalElapsed)

    //Errors intentionally uncaught so they are passed to invocation in reminders
    await queryPromise('INSERT INTO reminderCountdownComponents(reminderId, executionInterval, intervalElapsed) VALUES (?,?,?)',
        [reminderId, executionInterval, intervalElapsed])

}

//Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateCountdownComponents = async (reminderId, req) => {
    const executionInterval = Number(req.body.executionInterval)
    const intervalElapsed = Number(req.body.intervalElapsed)

    try {
        //If this succeeds: Reminder was not present in the countdown table and the timingStyle was changed. The old components will be deleted from the other table by reminders
        //If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
        await queryPromise('INSERT INTO reminderCountdownComponents(reminderId, executionInterval, intervalElapsed) VALUES (?,?,?)',
        [reminderId, executionInterval, intervalElapsed])
        return
    } catch (error) {

        //If this succeeds: Reminder was present in the countdown table, timingStyle didn't change, and the components were successfully updated
        //If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
        await queryPromise(
        'UPDATE reminderCountdownComponents SET executionInterval = ?, intervalElapsed = ? WHERE reminderId = ?',
            [executionInterval, intervalElapsed, reminderId ]
    )

    }

    
    /*
    //purposely throw errors to be caught my calling module
    if (!executionInterval && !intervalElapsed) {
        throw Error("Invalid Body; No executionInterval or intervalElapsed Provided")
    }
    if (executionInterval) {
        await queryPromise('UPDATE reminderCountdownComponents SET executionInterval = ? WHERE reminderId = ?',
            [executionInterval, reminderId ])
    }
    if (intervalElapsed) {
        await queryPromise('UPDATE reminderCountdownComponents SET intervalElapsed = ? WHERE reminderId = ?',
        [intervalElapsed, reminderId ])
    }
    */
    
}

module.exports = { createCountdownComponents, updateCountdownComponents }