
const formatDate = (date) => {

    if (date) {
        let modifiedDate = new Date(date)
        //if date is defined
        try {
            modifiedDate.toISOString().slice(0, 19).replace('T', ' ')
            //date in correct format
            return modifiedDate
        } catch (error) {
            //unable to convert format; incorrect format
            return undefined
        }
    }
    else {
        //date was not provided
        return undefined
    }
}

//this is needed as Boolean("string") always converts to true unless the string provided is ""
const formatBoolean = (string) => {
    if (string === "true" || string === "1" || string === 1){
        return true
    }
    else if (string === "false" || string === "0" || string === 0){
        return false
    }
    else {
        return undefined
    }
}

const isEmailValid = (email) => {

    var emailRegex = /^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$/;

    if (!email) {
        return false
    }
    if (email.length > 254) {
        return false
    }


    var valid = emailRegex.test(email)
    if (!valid) {
        return false
    }

    // Further checking of some things regex can't handle
    var parts = email.split("@")
    if (parts[0].length > 64) {
        return false
    }
    var domainParts = parts[1].split(".")
    if (domainParts.some(function (part) { return part.length > 63 })) {
        return false
    }

    return true
}

module.exports = { isEmailValid, formatDate, formatBoolean }
