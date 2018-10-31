const {
  environment
} = require('@rails/webpacker')
// const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const webpack = require('webpack')

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  // 'window.Tether': "tether",
  // Popper: ['popper.js', 'default'], // for Bootstrap 4
}))

environment.loaders.insert('font-awesome', {
  test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
  loader: "url-loader?limit=10000&mimetype=application/font-woff"
})
environment.loaders.insert('font-awesome', {
  test: /\.(ttf|eot)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
  loader: "file-loader"
})

// const envConfig = environment.loaders.append('vue', vue)
// module.exports = environment
// const aliasConfig = environment.loaders.append('vue', vue)
module.exports = {
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery'
    }
  }
}

environment.loaders.append('vue', vue)
module.exports = environment

