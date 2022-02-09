const { queryPromise } = require('../middleware/queryPromise')
const { formatDate } = require('../middleware/validateFormat')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) reminderId formatted correctly and request has sufficient permissions to use
*/


const getReminders = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const reminderId = Number(req.params.reminderId)

    //reminderId was provided
    if (reminderId){
        queryPromise('SELECT reminderId, reminderType, customTypeName, timingStyle, executionBasis, enabled FROM dogReminders WHERE reminderId = ?', [reminderId])
        .then((result) => res.status(200).json(result))
        .catch((err) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed' }))
    }
    //no reminderId
    else {
        try {
            const result = await queryPromise('SELECT reminderId, reminderType, customTypeName, timingStyle, executionBasis, enabled FROM dogReminders WHERE dogId = ?',
            [dogId])
    
            if (result.length === 0) {
                //successful but empty array, not reminders to return
                return res.status(204).json(result)
            }
            else {
                //array has items, meaning there were reminders found, successful!
                return res.status(200).json(result)
            }
    
        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed' })
        }
    }
} 

const createReminder = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const enabled = Boolean(req.body.enabled)

    if (!reminderType || !timingStyle || !executionBasis || !enabled){
        return res.status(400).json({ message: 'Invalid Body; Missing reminderType Or timingStyle Or executionBasis Or enabled' })
    }
    else if (reminderType === "Custom" && !customTypeName){
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" reminderType' })
    }

    return queryPromise('INSERT INTO dogReminders(dogId, reminderType, customTypeName, timingStyle, executionBasis, enabled) VALUES (?, ?, ?, ?, ?, ?)',
    [dogId,reminderType,customTypeName, timingStyle, executionBasis, enabled])
    .then((result) => res.status(200).json({message: "Success"}))
    .catch((err) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed; Check executionBasis Or reminderStyle Or timingStyle Format' }))
    
    //to do, add reminder components as well.
}

const updateReminder = async (req, res) => {

    const reminderId = Number(req.params.reminderId)
    const reminderType = req.body.reminderType
    const customTypeName = req.body.customTypeName
    const timingStyle = req.body.timingStyle
    const executionBasis = formatDate(req.body.executionBasis)
    const enabled = Boolean(req.body.enabled)

    if (!reminderId || !reminderType || !timingStyle || !executionBasis || !enabled){
        return res.status(400).json({ message: 'Invalid Body; No reminderId Or reminderType Or timingStyle Or executionBasis Or enabled Provided' })
    }
    else if (reminderType === "Custom" && !customTypeName){
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" reminderType' })
    }

    try {
        if (reminderType){
            if (reminderType === "Custom"){
                await queryPromise('UPDATE dogReminders SET reminderType = ?, customTypeName = ?  WHERE reminderId = ?', [reminderType, customTypeName, reminderId])
            }
            else {
                await queryPromise('UPDATE dogReminders SET reminderType = ? WHERE reminderId = ?', [reminderType, reminderId])
            }
            
        }
        if (timingStyle){
            await queryPromise('UPDATE dogReminders SET timingStyle = ? WHERE reminderId = ?', [timingStyle, reminderId])
        }
        if (executionBasis){
            await queryPromise('UPDATE dogReminders SET executionBasis = ? WHERE reminderId = ?', [executionBasis, reminderId])
        }
        if (typeof enabled !== 'undefined'){
            await queryPromise('UPDATE dogReminders SET enabled = ? WHERE reminderId = ?', [enabled, reminderId])
        }

        //to do, update reminder components
        return res.status(200).json({message: "Success"})
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed' })
    }
}
const delReminder = require('../middleware/delete').deleteReminder

const deleteReminder = async (req, res) => {
    const reminderId = Number(req.params.reminderId)

    return delReminder(reminderId)
    .then((result) => res.status(200).json({ message: "Success" }))
    .catch((err) => res.status(400).json({ message: 'Invalid Syntax; Database Query Failed' }))
}

module.exports = { getReminders, createReminder, updateReminder, deleteReminder }