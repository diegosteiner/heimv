const { generateWebpackConfig, merge } = require("shakapacker");
const customConfig = {
  resolve: {
    extensions: [".ts", ".tsx", ".jsx", ".css", ".scss"],
  },
  module: {
    rules: [
      {
        test: /\.(sc|sa|c)ss$/i,
        use: [
          {
            loader: require("mini-css-extract-plugin").loader,
          },
          {
            loader: "css-loader",
            options: {
              sourceMap: true,
              importLoaders: 2,
              modules: {
                localIdentName: "[path][name]__[local]--[hash:base64:5]",
                exportLocalsConvention: "camelCase",
              },
            },
          },
          {
            loader: "postcss-loader",
            options: {
              sourceMap: true,
            },
          },
          {
            loader: "sass-loader",
            options: {
              sourceMap: true,
              warnRuleAsWarning: true,
              sassOptions: {
                outputStyle: "compressed",
              },
            },
          },
        ],
        include: /\.module\.[a-z]+$/,
      },
      {
        test: /\.ya?ml$/,
        use: "yaml-loader",
      },
    ],
  },
};

module.exports = merge(generateWebpackConfig(), customConfig);
