process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

console.log(process.env.NODE_ENV)
console.log(environment.toWebpackConfig())

module.exports = environment.toWebpackConfig()
