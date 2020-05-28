# keep as commonjs requires for now
setup = require 'frontend-shared-dev/setup_gulp'

paths = require './gulp_paths'
Lang = require './src/lang'
config = require './src/config'

setup {paths, Lang, config}
