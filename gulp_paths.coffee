module.exports =
  static: './src/static/**/*'
  coffee: ['./*.coffee', './src/**/*.coffee']
  root: './src/root.coffee'
  sw: 'frontend-shared/service_worker/index.coffee'
  dist: './dist'
  build: './build'
  swBuild: './build/service_worker.js'
  manifest: [
    './dist/**/*'
    '!./dist/**/*.map'
    '!./dist/robots.txt'
    '!./dist/stats.json'
    '!./dist/manifest.html'
  ]
