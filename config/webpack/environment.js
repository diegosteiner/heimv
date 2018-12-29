const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

// const webpack = require('webpack')

// environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
//   $: 'jquery',
//   jQuery: 'jquery',
//   moment: 'moment',
//   // 'window.Tether': "tether",
//   // Popper: ['popper.js', 'default'], // for Bootstrap 4
// }))


environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment
