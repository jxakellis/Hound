const { queryPromise } = require('../middleware/queryPromise')
const { formatDate } = require('../middleware/validateFormat')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- dogId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) logId formatted correctly and request has sufficient permissions to use
*/


const getLogs = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const logId = Number(req.params.logId)

    //if logId is defined and it is a number then continue
    if (logId) {
        queryPromise('SELECT logId, date, note, logType, customTypeName FROM dogLogs WHERE logId = ?', [logId])
            .then((result) => res.status(200).json(result))
            .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error }))

    }
    else {
        try {
            const result = await queryPromise('SELECT logId, date, note, logType, customTypeName FROM dogLogs WHERE dogId = ?',
                [dogId])

            if (result.length === 0) {
                //successful but empty array, not logs to return
                return res.status(204).json(result)
            }
            else {
                //array has items, meaning there were logs found, successful!
                return res.status(200).json(result)
            }

        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error })
        }
    }
}

const createLog = async (req, res) => {
    const dogId = Number(req.params.dogId)
    const logDate = formatDate(req.body.date)
    const note = req.body.note
    const logType = req.body.logType
    const customTypeName = req.body.customTypeName

    if (!logDate || !logType) {
        return res.status(400).json({ message: 'Invalid Body; Missing date or logType' })
    }
    //see if logType is being updated to custom and tell the user to provide customTypeName if so.
    else if (logType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" logType' })

    }

    return queryPromise('INSERT INTO dogLogs(dogId, date, note, logType, customTypeName) VALUES (?, ?, ?, ?, ?)',
        [dogId, logDate, note, logType, customTypeName])
        .then((result) => res.status(200).json({ message: "Success", logId: result.insertId }))
        .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed; Check date Or logType Format', error: error }))

}

const updateLog = async (req, res) => {

    const logId = Number(req.params.logId)
    const logDate = formatDate(req.body.date)
    const note = req.body.note
    const logType = req.body.logType
    const customTypeName = req.body.customTypeName

    //if all undefined, then there is nothing to update
    if (!logDate && !note && !logType && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No date Or note Or logType Or customTypeName Provided' })
    }
    //proper stuff is defined, then check to see customTypeName provided
    else if (logType === "Custom" && !customTypeName) {
        return res.status(400).json({ message: 'Invalid Body; No customTypeName Provided for "Custom" logType' })

    }

    try {
        if (logDate) {
            await queryPromise('UPDATE dogLogs SET date = ? WHERE logId = ?', [logDate, logId])
        }
        if (note) {
            await queryPromise('UPDATE dogLogs SET note = ? WHERE logId = ?', [note, logId])
        }
        if (logType) {
            await queryPromise('UPDATE dogLogs SET logType = ? WHERE logId = ?', [logType, logId])
        }
        if (customTypeName) {
            await queryPromise('UPDATE dogLogs SET customTypeName = ? WHERE logId = ?', [customTypeName, logId])
        }
        return res.status(200).json({ message: "Success" })
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed; Check date Or logType Format', error: error })
    }
}


const delLog = require('../middleware/delete').deleteLog
const deleteLog = async (req, res) => {
    const logId = Number(req.params.logId)

    return delLog(logId)
        .then((result) => res.status(200).json({ message: "Success" }))
        .catch((error) => res.status(400).json({ message: 'Invalid Syntax; Database Query Failed', error: error }))
}

module.exports = { getLogs, createLog, updateLog, deleteLog }