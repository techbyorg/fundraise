/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import z from 'zorium'

import $spinner from 'frontend-shared/components/spinner'

import config from '../../config'
let $homePage

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default $homePage = ({ requestsStream, serverData, entity }) => z('.p-home',
  $spinner)
