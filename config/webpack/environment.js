const { environment, config } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const { join } = require('path')

// const webpack = require('webpack')

// environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
//   $: 'jquery',
//   jQuery: 'jquery',
//   moment: 'moment',
//   // 'window.Tether': "tether",
//   // Popper: ['popper.js', 'default'], // for Bootstrap 4
// }))

const fileLoader = environment.loaders.get('file')
fileLoader.use[0].options.name = '[path][name]-[hash].[ext]'
fileLoader.use[0].options.context = join(config.source_path) // optional if you don't want to expose full paths

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment
