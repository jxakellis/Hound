
const validateUserIdFormat = (req,res,next) => {
    const userId = req.params.userId

    if (userId && Number(userId)){
        //if userId is defined and it is a number then continue
        next()
    }
	else {
        //userId was not provided or is invalid
        return res.status(400).json({message:'User Id Invalid'})
    } 
}

const validateDogIdFormat = (req,res,next) => {
    const dogId = req.params.dogId

    if (dogId && Number(dogId)){
        //if dogId is defined and it is a number then continue
        next()
    }
	else {
        //dogId was not provided or is invalid
        return res.status(400).json({message:'Dog Id Invalid'})
    } 
}

module.exports = {validateUserIdFormat, validateDogIdFormat}
