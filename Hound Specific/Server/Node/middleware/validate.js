const database = require('../databaseConnection')
const { queryPromise } = require('./queryPromise')

const validateUserId = async (req, res, next) => {

    //later on use a token here to validate that they have permission to use the userId

    const userId = Number(req.params.userId)

    if (userId) {
        //if userId is defined and it is a number then continue
        try {
            //queries the database to find if the users table contains a user with the provided ID
            const result = await queryPromise('SELECT userId FROM users WHERE userId = ?', [userId])

            //checks array of JSON from query to find if userId is contained
            if (result.some(item => item.userId === userId)) {
                //userId exists in the table
                next()
            }
            else {
                //userId does not exist in the table
                return res.status(400).json({ message: 'Invalid Parameters; userId Not Found' })
            }
        } catch (err) {
            //couldn't query database to find userId
            return res.status(400).json({ message: 'Invalid Parameters; userId Invalid' })
        }
    }
    else {
        //userId was not provided or is invalid format
        return res.status(400).json({ message: 'Invalid Parameters; userId Invalid' })
    }
}

const validateDogId = async (req, res, next) => {

    //userId should be validated already

    const userId = Number(req.params.userId)
    const dogId = Number(req.params.dogId)

    //if dogId is defined and it is a number then continue
    if (dogId) {
        //query database to find out if user has permission for that dogId
        try {
            //finds what dogId (s) the user has linked to their userId
            const userDogIds = await queryPromise('SELECT dogs.dogId FROM dogs WHERE dogs.userId = ?', [userId])

            // search query result to find if the dogIds linked to the userId match the dogId provided, match means the user owns that dogId

             if (userDogIds.some(item => item.dogId === dogId)) {
                 //the dogId exists and it is linked to the userId, valid!
                next()
            }
            else {
                //the dogId does not exist and/or the user does not have access to that dogId
                return res.status(404).json({ message: 'Couldn\'t Find Resource; No Dogs Found or Invalid Permissions' })
            }
        } catch (err) {
            return res.status(400).json({ message: 'Invalid Parameters; Database Query Failed' })
        }
       
    }
    else {
        //dogId was not provided or is invalid
        return res.status(400).json({ message: 'Invalid Parameters; dogId Invalid' })
    }
}

const validateDogNameFormat = async (req, res, next) => {
    const dogName = req.body.dogName

    if (dogName) {
        //if dogName is defined so can continue
        next()
    }
    else {
        //dogName was not provided
        return res.status(400).json({ message: 'Invalid Body; No dogName Provided' })
    }
}

module.exports = { validateUserId, validateDogId, validateDogNameFormat }
