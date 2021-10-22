module.exports = {
  plugins: [
    require('postcss-next')({
      features: {
        customProperties: {
          warnings: false
        }
      }
    }),
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
}
