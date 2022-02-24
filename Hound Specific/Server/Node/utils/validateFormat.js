const e = require("express")

/**
 * Converts provided date into format needed for database. If any check fails, returns undefined. Otherwise, returns correctly formatted date.
 * @param {*} date 
 * @returns 
 */
const formatDate = (string) => {

    if (string) {
        let modifiedDate = new Date(string)
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

/**
 * Converts the provided string into a boolean. "true", "1", or 1 retuns true; "false", "0", or 0 returns false; all other values return undefined 
 * This is needed as Boolean("string") always converts to true unless the string provided is ""
 * @param {*} string 
 * @returns 
 */
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

/**
 * Converts the provided string into a number. Any finite number will successfully convert into a number. This is needed as Number("random") converts into NaN with type of number. This result circumvents the typeof blah === 'undefined' logic as its type is number even though its value is null/NaN/undefined.
 * @param {*} number 
 * @returns 
 */
const formatNumber = (string) => {
    string = Number(string)
    if (Number.isFinite(string) === true){
        return Number(string)
    }
    else {
        return undefined
    }
}

/**
 * Takes single object or array of objects. If ALL objects provided are defined, returns true. Otherwise, returns false. Behaves the same as atLeastOneDefined for single object.
 * @param {*} arr 
 * @returns 
 */
const areAllDefined = (arr) => {
    //array
    if (Array.isArray(arr) === true){
        //checks to see all objects in array are defined
        for (let i = 0; i < arr.length; i++){
            if (typeof arr[i] === 'undefined'){
                //single object in array is undefined so return false
                return false
            }
        }
        //all items are defined
        return true
    }
    //single object,  not array
    else {
        if (typeof arr === 'undefined'){
            //object not defined
            return false
        }
        //object is defined
        return true
    }
}

/**
 * Take single object or array of objects. If at least one object provided is defined, returns true. Otherwise, returns false. Behaves the same as areAllDefined for single object.
 * @param {*} arr 
 * @returns 
 */
const atLeastOneDefined = (arr) => {
    //array
    if (Array.isArray(arr) === true){
        let isObjectDefined = false
        //checks to see if at least one object in array is defined

        for (let i = 0; i < arr.length; i++){
            if (typeof arr[i] !== 'undefined'){
                //single object in array is defined so we can break loop as we are only looking for one defined
                isObjectDefined = true
                break
            }
        }

        if (isObjectDefined === true){
            return true
        }
        else {
            return false
        }
    }
    //single object,  not array
    else {
        if (typeof arr === 'undefined'){
            //object not defined
            return false
        }
        //object is defined
        return true
    }
}

/**
 * Takes a string. If the string provided passes the regex and length checks, it is a valid email and the function returns true. Otherwise, function returns false.
 * @param {*} email 
 * @returns 
 */
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

module.exports = { isEmailValid, areAllDefined, atLeastOneDefined, formatDate, formatBoolean, formatNumber }
