// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
// react/react-dom -> preact
import 'module-alias/register'

import setup from 'frontend-shared/services/setup_server'

import colors from './src/colors'
import config from './src/config'
import gulpPaths from './gulp_paths'
import $app from './src/app'
import Lang from './src/lang'
import Model from './src/models'

const app = setup({ config, colors, gulpPaths, $app, Lang, Model })

export default app
