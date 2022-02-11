const { queryPromise } = require('../middleware/queryPromise')

/*
Known:
- userId formatted correctly and request has sufficient permissions to use
- (if appliciable to controller) dogId formatted correctly and request has sufficient permissions to use
*/


const getDogs = async (req, res) => {

    const userId = Number(req.params.userId)
    const dogId = Number(req.params.dogId)

    //if dogId is defined and it is a number then continue
    if (dogId) {

        queryPromise('SELECT dogId, name, icon FROM dogs WHERE dogs.dogId = ?', [dogId])
            .then((result) => res.status(200).json(result))
            .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error }))

    }
    else {
        try {
            const result = await queryPromise('SELECT dogs.dogId, dogs.icon, dogs.name FROM dogs WHERE dogs.userId = ?',
                [userId])

            if (result.length === 0) {
                //successful but empty array, not dogs to return
                return res.status(204).json(result)
            }
            else {
                //array has items, meaning there were dogs found, successful!
                return res.status(200).json(result)
            }

        } catch (error) {
            //error when trying to do query to database
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error })
        }
    }
}

const createDog = async (req, res) => {

    const dogName = req.body.dogName

    const userId = Number(req.params.userId)

    //allow a user to have multiple dogs by the same name 
    return queryPromise('INSERT INTO dogs(userId, icon, name) VALUES (?,?,?)',
        [userId, undefined, dogName])
        .then((result) => res.status(200).json({ message: "Success", dogId: result.insertId }))
        .catch((error) => res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed', error: error }))
}

const updateDog = async (req, res) => {

    //could be updating dogName or icon

    const dogId = Number(req.params.dogId)
    const dogName = req.body.dogName
    const icon = req.body.icon

    //if dogName and icon are both undefined, then there is nothing to update
    if (!dogName && !icon) {
        return res.status(400).json({ message: 'Invalid Body; No dogName Or icon Provided' })
    }

    try {
        if (dogName) {
            //updates the dogName for the dogId provided, overship of this dog for the user have been verifiied
            await queryPromise('UPDATE dogs SET name = ? WHERE dogId = ?', [dogName, dogId])
        }
        if (icon) {
            //implement later
        }
        return res.status(200).json({ message: "Success" })
    } catch (error) {
        return res.status(400).json({ message: 'Invalid Body or Parameters; Database Query Failed', error: error })
    }
}



const deleteDog = async (req, res) => {

    const dogId = Number(req.params.dogId)
    const { deleteDog } = require('../middleware/delete')
    return deleteDog(dogId)
        .then((result) => res.status(200).json({ message: "Success" }))
        .catch((error) => res.status(400).json({ message: 'Invalid Parameters; Database Query Failed', error: error }))
}

module.exports = { getDogs, createDog, updateDog, deleteDog }