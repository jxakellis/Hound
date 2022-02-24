const { queryPromise } = require('../utils/queryPromise')
const { formatNumber, areAllDefined, atLeastOneDefined } = require('../utils/validateFormat')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/


const getDogs = async (req, res) => {

    const userId = formatNumber(req.params.userId)
    const dogId = formatNumber(req.params.dogId)

    //if dogId is defined and it is a number then continue
    if (dogId) {

        //queryPromise('SELECT dogId, name, icon FROM dogs WHERE dogs.dogId = ?', [dogId])
        queryPromise('SELECT * FROM dogs WHERE dogs.dogId = ?', [dogId])
            .then((result) => res.status(200).json({ message: 'Success', result: result }))
            .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.message }))

    }
    else {
        try {
            //const result = await queryPromise('SELECT dogId, icon, name FROM dogs WHERE dogs.userId = ?',
            const result = await queryPromise('SELECT * FROM dogs WHERE dogs.userId = ?',
                [userId])

            if (result.length === 0) {
                //successful but empty array, not dogs to return
                return res.status(204).json({ message: 'Success', result: result })
            }
            else {
                //array has items, meaning there were dogs found, successful!
                return res.status(200).json({ message: 'Success', result: result })
            }

        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.message })
        }
    }
}

const createDog = async (req, res) => {

    const userId = formatNumber(req.params.userId)
    const dogName = req.body.dogName
    //const icon = req.body.icon

    if (areAllDefined([dogName]) === false) {
        return res.status(400).json({ message: 'Invalid Body; dogName missing' })
    }

    //allow a user to have multiple dogs by the same name 
    return queryPromise('INSERT INTO dogs(userId, icon, name) VALUES (?,?,?)',
        [userId, undefined, dogName])
        .then((result) => res.status(200).json({ message: 'Success', dogId: result.insertId }))
        .catch((error) => res.status(400).json({ message: 'Invalid Body or Parameters; Database query failed', error: error.message }))
}

const updateDog = async (req, res) => {

    //could be updating dogName or icon

    const dogId = formatNumber(req.params.dogId)
    const dogName = req.body.dogName
    const icon = req.body.icon

    //if dogName and icon are both undefined, then there is nothing to update
    if (atLeastOneDefined([dogName, icon]) === false) {
        return res.status(400).json({ message: 'Invalid Body; No dogName or icon provided' })
    }

    try {
        if (dogName) {
            //updates the dogName for the dogId provided, overship of this dog for the user have been verifiied
            await queryPromise('UPDATE dogs SET name = ? WHERE dogId = ?', [dogName, dogId])
        }
        if (icon) {
            //implement later
        }
        return res.status(200).json({ message: 'Success' })
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database query failed', error: error.message })
    }
}



const deleteDog = async (req, res) => {

    const dogId = formatNumber(req.params.dogId)
    const { deleteDog } = require('../utils/delete')
    return deleteDog(dogId)
        .then((result) => res.status(200).json({ message: 'Success' }))
        .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database query failed', error: error.message }))
}

module.exports = { getDogs, createDog, updateDog, deleteDog }