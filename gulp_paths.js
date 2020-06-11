path = require 'path'

module.exports =
  static: path.join __dirname, './src/static/**/*'
  coffee: [path.join(__dirname, './*.coffee'), path.join(__dirname, './src/**/*.coffee')]
  root: path.join __dirname, './src/root.coffee'
  sw: './src/service_worker/index.coffee'
  dist: path.join __dirname, './dist'
  build: path.join __dirname, './build'
  swBuild: path.join __dirname, './build/service_worker.js'
  manifest: [
    path.join __dirname, './dist/**/*'
    '!' + path.join __dirname, './dist/**/*.map'
    '!' + path.join __dirname, './dist/robots.txt'
    '!' + path.join __dirname, './dist/stats.json'
    '!' + path.join __dirname, './dist/manifest.html'
  ]
