
const getLogin = (req, res ) => {
    

    if (String(req.body.email).toLowerCase === 'bobsmith@gmail.com'){
        if (token === 'Bobs Token') {
            res.status(200).json({message: 'Success'})
        }
        else {
            res.status(403).json({message: 'Password Invalid'})
        }
    }
    else {
        res.status(401).json({message: 'Email Invalid'})
    }
    //check for email and password

    //authenticate user

    //send token and user id
    //res.status(200).json({id: 1, token: 'Bobs Token', email: 'BobSmith@gmail.com', firstName: 'Bob', lastName: 'Smith'})
}

const createLogin = (req, res ) => {
    //check for email, first, last, and password

    //check email unique and valid

    //check password valid

    //add user to database
    res.status(200).json()
}

const updateLogin = (req, res ) => {

    const userId = req.params.userId
    const token = req.body.token

    if (Number(userId) === 1){
        if (token === 'Bobs Token') {
            res.status(200).json({message: 'Success'})
        }
        else {
            res.status(403).json({message: 'Token Invalid'})
        }
    }
    else {
        res.status(401).json({message: 'ID Invalid'})
    }
    //check for token

    //check for body components to be updated

    //update user in database

    
}

const deleteLogin = (req, res ) => {

    const userId = req.params.userId
    const token = req.body.token

    if (Number(userId) === 1){
        if (token === 'Bobs Token') {
            res.status(200).json({message: 'Success'})
        }
        else {
            res.status(403).json({message: 'Token Invalid'})
        }
    }
    else {
        res.status(401).json({message: 'ID Invalid'})
    }

    //check for token

    //delte user from database
}

module.exports = {getLogin, createLogin, updateLogin, deleteLogin }