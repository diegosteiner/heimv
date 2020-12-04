const { environment, config } = require('@rails/webpacker')
const { join } = require('path')

const fileLoader = environment.loaders.get('file')
fileLoader.use[0].options.name = '[path][name]-[hash].[ext]'
fileLoader.use[0].options.esModule = false,
  fileLoader.use[0].options.context = join(config.source_path) // optional if you don't want to expose full paths

environment.mode = process.env.NODE_ENV || 'production'
environment.splitChunks()

module.exports = environment
