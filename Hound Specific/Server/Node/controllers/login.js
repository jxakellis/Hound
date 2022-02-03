const database = require('../databaseConnection')
const { queryPromise } = require('../middleware/queryPromise')

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getLogin = async (req, res) => {

    //add authentication

    const email = req.body.email.toLowerCase()
    //const password = req.body.password

    try {
        //query database to see if email is in it
        const userInformation = await queryPromise('SELECT * FROM users WHERE userEmail = ?', [email.toLowerCase()])

        if (userInformation.some(item => item.userEmail === email)) {
            //the userEmail exists, return all user data
            return res.status(200).json(user)
       }
       else {
           //the dogId does not exist and/or the user does not have access to that dogId
           return res.status(404).json({ message: 'Invalid Body; No User Found' })
       }
        
    } catch (err) {
        //query to database failed
        return res.status(400).json({ message: 'Invalid Body; Database Query Failed' })
    }
}

const createLogin = async (req, res) => {

    const email = req.body.email.toLowerCase()
    //const password = req.body.password
    const firstName = req.body.firstName
    const lastName = req.body.lastName

    //component of the body is missing or invalid
    if (!email || !firstName || !lastName) {
        return res.status(400).json({ message: 'Invalid Body; Missing email, firstName, or lastName' })
    }
    else {
        //insert values into database
        queryPromise('INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
            [firstName, lastName, email])
            //everything worked
            .then((result)=>res.status(200).json({message: "Success"}))
            //something went wrong; the only reasonable option is that the email is a duplicate (possible others like varchar limit but unlikely) 
            .catch((err)=>res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible Duplicate Email' }))
    }
}

const updateLogin = async (req, res) => {

    const userId = Number(req.params.userId)
    const email = req.body.email.toLowerCase()
    //const password = req.body.password
    const firstName = req.body.firstName
    const lastName = req.body.lastName

    if (!email && !firstName && lastName){
        return res.status(400).json({ message: 'Invalid Body; Provide email, firstName, and/or lastName To Update' })
    }
    else {
        try {
            if (email){
                queryPromise('UPDATE users SET userEmail = ? WHERE userId = ?',
                [email,userId])
            }
            if (firstName){
                queryPromise('UPDATE users SET userFirstName = ? WHERE userId = ?',
                [firstName,userId])
            }
            if (lastName){
                queryPromise('UPDATE users SET userLastName = ? WHERE userId = ?',
                [lastName,userId])
            }
            return res.status(200).json({message:"Success"})
        } catch (err) {
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible Duplicate Email' })
        }
    }


}

const deleteLogin = async (req, res) => {

    const userId = Number(req.params.userId)

    return queryPromise('DELETE FROM users WHERE userId = ?', [user])
            .then((result)=>res.status(200).json({message: "Success"}))
            .catch((err)=>res.status(400).json({ message: 'Invalid Syntax; Database Query Failed' }))
}

module.exports = { getLogin, createLogin, updateLogin, deleteLogin }