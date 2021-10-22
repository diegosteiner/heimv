const { webpackConfig, merge, isDevelopment } = require('@rails/webpacker')
const customConfig = {
  resolve: {
    extensions: ['.ts', '.tsx', '.jsx', '.css', '.scss']
  },
  module: {
    rules: [
      {
        test: /\.(scss|sass)$/i,
        use: [
          {
            loader: require('mini-css-extract-plugin').loader,
          },
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
              importLoaders: 2,
              modules: {
                localIdentName: '[path][name]__[local]--[hash:base64:5]',
                exportLocalsConvention: 'camelCase',
              },
            },
          },
          {
            loader: 'postcss-loader',
            options: {
              sourceMap: true,
            },
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              sassOptions: {
                outputStyle: 'compressed',
              },
            },
          },
        ],
        include: /\.module\.[a-z]+$/
      },
    ],
  }
}

// const { join } = require('path')
// const fileLoader = environment.rules.get('file')
// fileLoader.use[0].options.name = '[path][name]-[hash].[ext]'
// fileLoader.use[0].options.esModule = false,
//   fileLoader.use[0].options.context = join(config.source_path) // optional if you don't want to expose full paths

// environment.mode = process.env.NODE_ENV || 'production'
// environment.splitChunks()

module.exports = merge(webpackConfig, customConfig)
