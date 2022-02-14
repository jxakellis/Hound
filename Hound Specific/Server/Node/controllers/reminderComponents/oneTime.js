const { queryPromise } = require('../../middleware/queryPromise')
const { formatDate } = require('../../middleware/validateFormat')

const createOneTimeComponents = async (reminderId, req) => {
    const date = formatDate(req.body.date)

     //Errors intentionally uncaught so they are passed to invocation in reminders
   await queryPromise('INSERT INTO reminderOneTimeComponents(reminderId, date) VALUES (?,?)',
   [reminderId,date])
}

//Attempts to first add the new components to the table. iI this fails then it is known the reminder is already present or components are invalid. If the update statement fails then it is know the components are invalid, error passed to invocer.
const updateOneTimeComponents = async (reminderId, req) => {
    const date = formatDate(req.body.date)

    try {
        //If this succeeds: Reminder was not present in the weekly table and the timingStyle was changed. The old components will be deleted from the other table by reminders
        //If this fails: The components provided are invalid or reminder already present in table (reminderId UNIQUE in DB)
        await queryPromise('INSERT INTO reminderOneTimeComponents(reminderId, date) VALUES (?,?)',
   [reminderId,date])
        return
    } catch (error) {
        
        //If this succeeds: Reminder was present in the weekly table, timingStyle didn't change, and the components were successfully updated
        //If this fails: The components provided are invalid. It is uncaught here to intentionally be caught by invocation from reminders.
        await queryPromise('UPDATE reminderOneTimeComponents SET date = ? WHERE reminderId = ?',
     [date,reminderId])
    }

     //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
    

   
    /*
    if (!date){
        throw Error("Invalid Body; No date Provided")
    }
    else {
        await queryPromise('UPDATE reminderOneTimeComponents SET date = ? WHERE reminderId = ?',
   [date,reminderId])
    }
    return
    */
    
}

module.exports = { createOneTimeComponents, updateOneTimeComponents }