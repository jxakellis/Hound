const { queryPromise } = require('../../middleware/queryPromise')
const { formatDate } = require('../../middleware/validateFormat')

const createOneTimeComponents = async (reminderId, req) => {
    const date = formatDate(req.body.date)

     //if there is an error, it is uncaught to intentionally be caught by invocation from reminders
   await queryPromise('INSERT INTO reminderOneTimeComponents(reminderId, date) VALUES (?,?)',
   [reminderId,date])
   return
}

const updateOneTimeComponents = async (reminderId, req) => {
    const date = formatDate(req.body.date)

    if (!date){
        throw Error("Invalid Body; No date Provided")
    }
    else {
        await queryPromise('UPDATE reminderOneTimeComponents SET date = ? WHERE reminderId = ?',
   [date,reminderId])
    }
    return
}

module.exports = { createOneTimeComponents, updateOneTimeComponents }