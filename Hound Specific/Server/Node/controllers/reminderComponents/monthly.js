const { queryPromise } = require('../../middleware/queryPromise')
const { formatDate, formatBoolean } = require('../../middleware/validateFormat')

const createMonthlyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const dayOfMonth = Number(req.body.dayOfMonth)

    //Errors intentionally uncaught so they are passed to invocation in reminders
    //Newly created monthly reminder cant be skipping, so no need for skip data
  await queryPromise('INSERT INTO reminderMonthlyComponents(reminderId, hour, minute, dayOfMonth) VALUES (?,?,?,?)',
  [reminderId,hour,minute,dayOfMonth])

}

//Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateMonthlyComponents = async (reminderId, req) => {
    const hour = Number(req.body.hour)
    const minute = Number(req.body.minute)
    const dayOfMonth = Number(req.body.dayOfMonth)
    const skipping = formatBoolean(req.body.skipping)
    const skipDate = formatDate(req.body.skipDate)

    try {
        //If this succeeds: Reminder was not present in the monthly table and the timingStyle was changed. The old components will be deleted from the other table by reminders
        //If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
        await queryPromise('INSERT INTO reminderMonthlyComponents(reminderId, hour, minute, dayOfMonth) VALUES (?,?,?,?)',
        [reminderId,hour,minute,dayOfMonth])
        return
    } catch (error) {
        
        //If this succeeds: Reminder was present in the monthly table, timingStyle didn't change, and the components were successfully updated
        //If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
         if (skipping === true){
            await queryPromise('UPDATE reminderMonthlyComponents SET hour = ?, minute = ?, dayOfMonth = ?, skipping = ?, skipDate = ? WHERE reminderId = ?',
            [hour, minute, dayOfMonth, skipping, skipDate, reminderId])
        }
        else {
            await queryPromise('UPDATE reminderMonthlyComponents SET hour = ?, minute = ?, dayOfMonth = ?, skipping = ?  WHERE reminderId = ?',
            [hour, minute, dayOfMonth, skipping, reminderId])
        }
    }


    //if (skipping === true && !skipDate){
        //throw Error("skipDate invalid or not provided")
    //}
   // else {

    //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
        
 //   }

    /*
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
                await queryPromise('UPDATE reminderMonthlyComponents SET skipping = ?, skipDate = ? WHERE reminderId = ?',
            [skipping, skipDate, reminderId])
            }
            //no need for skipdate if skipping turning false
            else {
                await queryPromise('UPDATE reminderMonthlyComponents SET skipping = ?, skipDate = ? WHERE reminderId = ?',
            [skipping, undefined, reminderId])
            }
        }
        return
    }
    */
}

module.exports = { createMonthlyComponents, updateMonthlyComponents }