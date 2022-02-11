const { queryPromise } = require('../../middleware/queryPromise')

/* KNOWN:
- reminderId defined
*/

const createCountdownComponents = async (reminderId, req) => {
    const executionInterval = Number(req.body.executionInterval)
    const intervalElapsed = Number(req.body.intervalElapsed)

    //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
    await queryPromise('INSERT INTO reminderCountdownComponents(reminderId, executionInterval, intervalElapsed) VALUES (?,?,?)',
        [reminderId, executionInterval, intervalElapsed])

}

//update the countdown components in the reminderCountdownComponents table. Does not do any deletion from other tables, simply updates.
const updateCountdownComponents = async (reminderId, req) => {
    const executionInterval = Number(req.body.executionInterval)
    const intervalElapsed = Number(req.body.intervalElapsed)

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
    return
}

module.exports = { createCountdownComponents, updateCountdownComponents }