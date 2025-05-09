const path = require('path');

module.exports = {
  publicPath: './',
  assetsDir: 'assets',
  chainWebpack: config => {
    config.output
      .filename('assets/[name].[contenthash:8].js')
      .chunkFilename('assets/[name].[contenthash:8].js');

    if (config.plugins.has('extract-css')) {
      config.plugin('extract-css').tap(args => {
        args[0].filename = 'assets/[name].[contenthash:8].css';
        args[0].chunkFilename = 'assets/[name].[contenthash:8].css';
        return args;
      });
    }

    config.module
      .rule('images')
      .set('generator', {
        filename: 'assets/[name][ext]'
      });
  }
}; 
