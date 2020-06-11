/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { z } from 'zorium'

import $spinner from 'frontend-shared/components/spinner'

import config from '../../config'

if (typeof window !== 'undefined') { require('./index.styl') }

export default function $homePage ({ requestsStream, serverData, entity }) {
  return z('.p-home', $spinner)
}
