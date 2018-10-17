const path = require('path');

module.exports = {
  entry: [
    path.join(__dirname, 'src/css/entry.css'),
    path.join(__dirname, 'src/js/entry.js')
  ],
  output: {
    path: path.join(__dirname, 'static'),
    filename: 'js/bundle.js'
  },
  mode: 'production',
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /(node_modules)/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015']
        }
      }, {
        test: /\.css$/,
        loader: 'file-loader',
        options: {
          name: 'bundle.css',
          outputPath: 'css/'
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
