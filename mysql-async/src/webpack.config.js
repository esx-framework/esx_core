const path = require('path');

module.exports = {
  entry: './mysql.js',
  target: 'node',
  mode: 'production',
  output: {
    filename: 'mysql-async.js',
    path: path.resolve(__dirname, '..'),
  },
  optimization: {
    minimize: false,
  },
};
