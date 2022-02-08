const database = require('../databaseConnection')
const { queryPromise } = require('../middleware/queryPromise')
const { isEmailValid } = require('../middleware/validate')

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getLogin = async (req, res) => {

    let email = req.body.email
    const userId = Number(req.params.userId)

    //if the users provides an email and a userId then we don't know what to look for as those could be linked to different accounts
    if (email && userId) {
        return res.status(400).json({ message: "Invalid Parameters or Body; email And userId Provided, Pick One" })
    }
    //userId method of finding corresponding user
    else if (userId) {
        //in theory no authentication needed as /:userId triggers authentication middleware
        //in addition, only one user should exist for any userId otherwise the table is broken

        return queryPromise('SELECT * FROM users WHERE userId = ?',
            [userId])
            .then((result) => res.status(200).json(result))
            .catch((err) => res.status(400).json({ message: 'Invalid Parameters; userId Not Found' }))
    }
    //email method of finding corresponding user(s)
    else {
        
        if (isEmailValid(email) === false) {
            return res.status(400).json({ message: 'Invalid Body; Invalid email' })
        }
        //email valid, can convert to lower case without producing error
        email = req.body.email.toLowerCase()

        //const password = req.body.password

        try {
            //query database to see if email is in it
            const userInformation = await queryPromise('SELECT * FROM users WHERE userEmail = ?', [email.toLowerCase()])

            if (userInformation.some(item => item.userEmail === email)) {
                //the userEmail exists, return all user data
                return res.status(200).json(userInformation)
            }
            else {
                //the email does not exist
                return res.status(404).json({ message: 'Invalid Body; No User Found' })
            }

        } catch (err) {
            //query to database failed
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed' })
        }
    }


}

const createLogin = async (req, res) => {

    let email = req.body.email

    if (isEmailValid(email) === false) {
        return res.status(400).json({ message: 'Invalid Body; Invalid email' })
    }
    //email valid, can convert to lower case without producing error
    email = req.body.email.toLowerCase()


    //const password = req.body.password
    const firstName = req.body.firstName
    const lastName = req.body.lastName

    //component of the body is missing or invalid
    if (!firstName || !lastName) {
        return res.status(400).json({ message: 'Invalid Body; Missing firstName or lastName' })
    }
    else {
        //insert values into database
        queryPromise('INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
            [firstName, lastName, email])
            //everything worked
            .then((result) => res.status(200).json({ message: "Success" }))
            //something went wrong; the only reasonable option is that the email is a duplicate (possible others like varchar limit but unlikely) 
            .catch((err) => res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible Duplicate Email' }))
    }
}

const updateLogin = async (req, res) => {

    const userId = Number(req.params.userId)
    let email = req.body.email
    //const password = req.body.password
    const firstName = req.body.firstName
    const lastName = req.body.lastName

    if (!email && !firstName && lastName) {
        return res.status(400).json({ message: 'Invalid Body; Provide email, firstName, and/or lastName To Update' })
    }
    else {
        try {
            if (email) {
                
                if (isEmailValid(email) === false) {
                    return res.status(400).json({ message: 'Invalid Body; Invalid email' })
                }
                //email valid, can convert to lower case without producing error
                email = req.body.email.toLowerCase()

                queryPromise('UPDATE users SET userEmail = ? WHERE userId = ?',
                    [email, userId])
            }
            if (firstName) {
                queryPromise('UPDATE users SET userFirstName = ? WHERE userId = ?',
                    [firstName, userId])
            }
            if (lastName) {
                queryPromise('UPDATE users SET userLastName = ? WHERE userId = ?',
                    [lastName, userId])
            }
            return res.status(200).json({ message: "Success" })
        } catch (err) {
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible Duplicate Email' })
        }
    }


}

const deleteLogin = async (req, res) => {

    const userId = Number(req.params.userId)

    const {deleteUser} = require('../middleware/delete')

    return deleteUser(userId)
        .then((result) => res.status(200).json({ message: "Success" }))
        .catch((err) => res.status(400).json({ message: 'Invalid Syntax; Database Query Failed' }))
}


module.exports = { getLogin, createLogin, updateLogin, deleteLogin }