const { queryPromise } = require('../../middleware/queryPromise')
const { formatDate, formatBoolean } = require('../../middleware/validateFormat')

const createMonthlyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const dayOfMonth = Number(req.body.dayOfMonth)

    //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
  await queryPromise('INSERT INTO reminderMonthlyComponents(reminderId, hour, minute, dayOfMonth) VALUES (?,?,?,?)',
  [reminderId,hour,minute,dayOfMonth])
  return

}

const updateMonthlyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const dayOfMonth = Number(req.body.dayOfMonth)
    const skipping = formatBoolean(req.body.skipping)
    const skipDate = formatDate(req.body.skipDate)

    //there is no value to update, so there is a problem
    if (!hour||!minute||!dayOfMonth|| typeof skipping === 'undefined'){
        throw Error("No hour, minute, dayOfMonth, or skipping provided")
    }
    //if the reminder is turning into skipping mode, then it needs a skipDate to define when it was skipped
    else if (skipping === true && !skipDate){
        throw Error("skipDate invalid or not provided")
    }
    else {
        if (hour){
            await queryPromise('UPDATE reminderMonthlyComponents SET hour = ? WHERE reminderId = ?',
            [hour, reminderId])
        }
        if (minute){
            await queryPromise('UPDATE reminderMonthlyComponents SET minute = ? WHERE reminderId = ?',
            [minute, reminderId])
        }
        if (dayOfMonth){
            await queryPromise('UPDATE reminderMonthlyComponents SET dayOfMonth = ? WHERE reminderId = ?',
            [dayOfMonth, reminderId])
        }
        if (typeof skipping !== 'undefined'){
            //need skipdate if skipping turning true
            if (skipping === true){
                await queryPromise('UPDATE reminderMonthlyComponents SET skipping = ? AND skipDate = ? WHERE reminderId = ?',
            [skipping, skipDate, reminderId])
            }
            //no need for skipdate if skipping turning false
            else {
                await queryPromise('UPDATE reminderMonthlyComponents SET skipping = ? AND skipDate = ? WHERE reminderId = ?',
            [skipping, undefined, reminderId])
            }
        }
        return
    }
}

module.exports = { createMonthlyComponents, updateMonthlyComponents }