const database = require('../databaseConnection')
const { queryPromise } = require('../middleware/queryPromise')
const { isEmailValid } = require('../middleware/validateFormat')
const { getConfiguration, createConfiguration, updateConfiguration } = require('./configuration')

/*
Known:
- (if appliciable to controller) userId formatted correctly and request has sufficient permissions to use
*/

const getUser = async (req, res) => {

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
        try {
            const userInformation = await queryPromise('SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userId = ?',
                [userId])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                return res.status(204).json(userInformation)
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                return res.status(200).json(userInformation)
            }
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Parameters; user Not Found', error: error })
        }
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
            const userInformation = await queryPromise('SELECT * FROM users LEFT JOIN userConfiguration ON users.userId = userConfiguration.userId WHERE users.userEmail = ?',
                [email.toLowerCase()])

            if (userInformation.length === 0) {
                //successful but empty array, no user to return
                return res.status(204).json(result)
            }
            else {
                //array has item(s), meaning there was a user found, successful!
                return res.status(200).json(userInformation)
            }
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed', error: error })
        }
    }


}

const createUser = async (req, res) => {

    let email = req.body.email

    if (isEmailValid(email) === false) {
        return res.status(400).json({ message: 'Invalid Body; Invalid email' })
    }
    //email valid, can convert to lower case without producing error
    email = req.body.email.toLowerCase()


    const firstName = req.body.firstName
    const lastName = req.body.lastName

    //component of the body is missing or invalid
    if (!firstName || !lastName) {
        return res.status(400).json({ message: 'Invalid Body; Missing firstName or lastName' })
    }
    else {
        let userId = undefined
        try {
            //insert values into database
            await queryPromise('INSERT INTO users(userFirstName, userLastName, userEmail) VALUES (?,?,?)',
                [firstName, lastName, email])
                //everything worked
                .then((result) => userId = result.insertId)
            await createConfiguration(userId, req)

            return res.status(200).json({ message: "Success", userId: userId })
        } catch (error) {
            if (typeof userId !== 'undefined'){
                await delUser(userId)
                .catch((error)=>"do nothing")
            }
            //something went wrong; the most likely option is that the email is a duplicate
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible duplicate email or missing userConfiguration values', error: error })
        }

    }
}

const updateUser = async (req, res) => {

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
        } catch (error) {
            return res.status(400).json({ message: 'Invalid Body; Database Query Failed; Possible Duplicate Email', error: error })
        }
    }


}

const delUser  = require('../middleware/delete').deleteUser

const deleteUser = async (req, res) => {

    const userId = Number(req.params.userId)

    return delUser(userId)
        .then((result) => res.status(200).json({ message: "Success" }))
        .catch((error) => res.status(400).json({ message: 'Invalid Syntax; Database Query Failed', error: error }))
}


module.exports = { getUser, createUser, updateUser, deleteUser }