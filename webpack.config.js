var webpack = require('webpack');
var react = require('react');

module.exports = {
  entry: './client/router.cjsx',
  output: {
    path: 'static',
    filename: 'app.js'
  },
  module: {
    loaders: [
      {
        test: /\.cjsx$/,
        loaders: ['coffee', 'cjsx']
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.cjsx']
  },
  resolveLoader: {
    modulesDirectories: ['node_modules']
  },
};
