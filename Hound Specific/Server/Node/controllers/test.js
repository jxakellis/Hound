const getTest = async (req, res) => {
    console.log('logger controller')
    console.log(req.params)
    console.log(req.foo)
    return res.status(200).json({message:"test"})
}

module.exports = {getTest}