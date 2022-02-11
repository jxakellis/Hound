const { queryPromise } = require('../../middleware/queryPromise')
const { formatDate, formatBoolean } = require('../../middleware/validateFormat')

const createWeeklyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const sunday = formatBoolean(req.body.sunday)
    const monday = formatBoolean(req.body.monday)
    const tuesday = formatBoolean(req.body.tuesday)
    const wednesday = formatBoolean(req.body.wednesday)
    const thursday = formatBoolean(req.body.thursday)
    const friday = formatBoolean(req.body.friday)
    const saturday = formatBoolean(req.body.saturday)

    //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
    await queryPromise('INSERT INTO reminderWeeklyComponents(reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday) VALUES (?,?,?,?,?,?,?,?,?,?)'
        , [reminderId, hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday])
    return
}

const updateWeeklyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const sunday = formatBoolean(req.body.sunday)
    const monday = formatBoolean(req.body.monday)
    const tuesday = formatBoolean(req.body.tuesday)
    const wednesday = formatBoolean(req.body.wednesday)
    const thursday = formatBoolean(req.body.thursday)
    const friday = formatBoolean(req.body.friday)
    const saturday = formatBoolean(req.body.saturday)
    const skipping = formatBoolean(req.body.skipping)
    const skipDate = formatDate(req.body.skipDate)

    //there is no value to update, so there is a problem
    if (!hour && !minute 
    && typeof sunday === 'undefined' && typeof monday === 'undefined' 
    && typeof tuesday === 'undefined' && typeof wednesday === 'undefined' 
    && typeof thursday === 'undefined' && typeof friday === 'undefined' 
    && typeof saturday === 'undefined' && typeof skipping === 'undefined') {
        throw Error("No hour, minute, sunday, monday, tuesday, wednesday, thursday, friday, saturday, or skipping provided")
    }
    //if the reminder is turning into skipping mode, then it needs a skipDate to define when it was skipped
    else if (skipping === true && !skipDate) {
        throw Error("skipDate invalid or not provided")
    }
    else {
        if (hour) {
            await queryPromise('UPDATE reminderWeeklyComponents SET hour = ? WHERE reminderId = ?',
                [hour, reminderId])
        }
        if (minute) {
            await queryPromise('UPDATE reminderWeeklyComponents SET minute = ? WHERE reminderId = ?',
                [minute, reminderId])
        }
        if (typeof sunday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET sunday = ? WHERE reminderId = ?',
                [sunday, reminderId])
        }
        if (typeof monday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET monday = ? WHERE reminderId = ?',
                [monday, reminderId])
        }
        if (typeof tuesday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET tuesday = ? WHERE reminderId = ?',
                [tuesday, reminderId])
        }
        if (typeof wednesday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET wednesday = ? WHERE reminderId = ?',
                [wednesday, reminderId])
        }
        if (typeof thursday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET thursday = ? WHERE reminderId = ?',
                [thursday, reminderId])
        }
        if (typeof friday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET friday = ? WHERE reminderId = ?',
                [friday, reminderId])
        }
        if (typeof saturday !== 'undefined') {
            await queryPromise('UPDATE reminderWeeklyComponents SET saturday = ? WHERE reminderId = ?',
                [saturday, reminderId])
        }
        if (typeof skipping !== 'undefined') {
            //need skipdate if skipping turning true
            if (skipping === true) {
                await queryPromise('UPDATE reminderWeeklyComponents SET skipping = ? AND skipDate = ? WHERE reminderId = ?',
                    [skipping, skipDate, reminderId])
            }
            //no need for skipdate if skipping turning false
            else {
                await queryPromise('UPDATE reminderWeeklyComponents SET skipping = ? AND skipDate = ? WHERE reminderId = ?',
                    [skipping, undefined, reminderId])
            }
        }
        return
    }

}

module.exports = { createWeeklyComponents, updateWeeklyComponents }