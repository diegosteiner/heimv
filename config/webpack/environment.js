const {
    environment
} = require('@rails/webpacker')
const webpack = require('webpack')

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.set('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    // 'window.Tether': "tether",
    // Popper: ['popper.js', 'default'], // for Bootstrap 4
}))

const envConfig = module.exports = environment
const aliasConfig = module.exports = {
    resolve: {
        alias: {
            jquery: 'jquery/src/jquery'
        }
    }
}

module.exports = environment
