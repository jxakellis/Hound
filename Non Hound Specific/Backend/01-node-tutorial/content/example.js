const {createReadStream} = require('fs');

const stream = createReadStream('./big.txt', {highWaterMark: 90000, encoding: 'utf8'})

stream.on('data', (chunk) => {
    console.log(chunk)
})

stream.on('error', (err) => {
    console.log(err)
})