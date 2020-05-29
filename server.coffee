import setup from 'frontend-shared/services/setup_server'

import config from './src/config'
console.log 'server'
import gulpPaths from './gulp_paths'
import $app from './src/app'
import Lang from './src/lang'
import Model from './src/models'

app = setup {config, gulpPaths, $app, Lang, Model}

export default app
