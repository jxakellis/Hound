const express = require('express');
const app = express()

app.use(express.static('./methods-public'))

app.listen(5000, () => {
    console.log('listening on port 5000')
})

app.use(express.urlencoded({extended: false}))

app.post('/login', (req,res) => {
    console.log(req.body)
    res.send('POST')
})

app.get('/', (req, res) => {
    res.json([{name: 'sda'}, {name:'dsadf'}])
})

app.all('*', (req,res)=>{
    res.status(404).send('not found')
})