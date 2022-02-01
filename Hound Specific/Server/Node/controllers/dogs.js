const database = require('../databaseConnection')

//known: userId and dogId have been validated

const getDogs = (req, res) => {

    const userId = req.params.userId

    database.query('SELECT dogs.dogId, dogs.icon, dogs.name FROM dogs WHERE dogs.userId = ?',
        [userId], (err, result, fields) => {
            if (err) {
                //error when trying to do query to database
                res.status(400).json({ message: 'Invalid Syntax' })
            }
            else if (result.length === 0) {
                //empty array
                res.status(204).json(result)
            }
            else {
                //array has items, meaning there were dogs found, successful!
                res.status(200).json(result)
            }

        })
}

const createDog = (req, res) => {

    //check that dogName is defined
    if (!req.body.dogName) {
        //dogName is undefined
        return res.status(400).json({ message: 'Invalid Body'})
    }

    const userId = req.params.userId

    //allow a user to have multiple dogs by the same name 
    database.query('INSERT INTO dogs(userId, icon, name) VALUES (?,?,?)',
                        [Number(req.params.userId), undefined, req.body.dogName],
                        (err, result, fields) => {
                            if (err) {
                                //error when trying to do query to database
                                return res.status(400).json({ message: 'Invalid Syntax'})
                            }
                            else {
                                //success
                                return res.status(200).json()
                            }
                        })

    //dont allow user to have more that one dog of a specific name (IF CHANGED BACK TO THIS SETUP THEN updateDog MUST BE MODIFIED TO CHECK FOR DUPLICATES AS WELL)

    /* //query to check that dog name is not a repeat, after which it will properly insert the vlaues
    database.query('SELECT dogs.name FROM dogs WHERE dogs.userId = ?',
        [userId],
        (err, result, fields) => {
            if (err) {
                //error when trying to do query to database to check for repeat dogName
                return res.status(400).json({ message: 'Invalid Syntax' })
            }
            else {
                if (result.some(item => item.name === req.body.dogName)) {
                    //the database already has a dog by that name for that user so dog creation is invalid
                    return res.status(400).json({ message: 'Invalid Body' })
                }
                else {
                    //no dog by that name exists for the given user meaning new dog name is unique
                    database.query('INSERT INTO dogs(userId, icon, name) VALUES (?,?,?)',
                        [Number(req.params.userId), undefined, req.body.dogName],
                        (err, result, fields) => {
                            if (err) {
                                //error when trying to do query to database
                                return res.status(400).json({ message: 'Invalid Syntax' })
                            }
                            else {
                                //success
                                return res.status(200).json()
                            }
                        })
                }
            }

        }) */

}

const updateDog = (req, res) => {
    //could be updating dogName or icon

    const userId = req.params.userId
    const dogId = req.params.dogId
    const dogName = req.body.dogName

    //finds what dogId (s) the user has linked to their userId

    //turn into promises

    database.query('SELECT dogs.dogId FROM dogs WHERE dogs.userId = ?',
        [userId], (err, result, fields) => {
            if (err) {
                //error when trying to do query to database
                return res.status(400).json({ message: 'Invalid Syntax'})
            }
            else if (result.some(item => item.dogId === req.params.dogId)) {
                //the user is permitted to access their provided dogId (one of the results of dogId (s) attached to their userId matched the provided dogId)
                
                //dogName defined
                if (dogName){
                    database.query('UPDATE dogs SET dogName = ? WHERE dogId = ?',
                    [dogName,dogId],
                    (err, result, fields) => {
                        if (err){
                            //DOESNT WORK
                            return res.status(400).json({ message: 'Invalid Dog Name'})
                        }
                    })
                }
                //icon defined
                if (icon){
                    //implement later
                }
            }
            else {
                //the dogId does not exist and/or the user does not have access to that dogId
                return res.status(400).json({ message: 'Invalid Syntax'})
            }

        })
}

const deleteDog = (req, res) => {
    res.status(200).json()
}

module.exports = { getDogs, createDog, updateDog, deleteDog }