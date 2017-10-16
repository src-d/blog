const path = require('path');

module.exports = {
  // webpack folder's entry js - excluded from jekll's build process.
  entry: path.join(__dirname, "js/entry.js"),
  output: {
    // we're going to put the generated file in the assets folder so jekyll will grab it.
      path: path.join(__dirname, 'static/js/'),
      filename: "bundle.js"
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /(node_modules)/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015']
        }
      }
    ]
  },

  resolve: {
    extensions: ['js', 'jsx'],
    modules: ['node_modules'],
    symlinks: false,
  }
};
