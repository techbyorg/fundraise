import z from 'zorium'

import $spinner from 'frontend-shared/components/spinner'

import config from '../../config'

if window?
  require './index.styl'

module.exports = $homePage = ({requestsStream, serverData, entity}) ->
  z '.p-home',
    $spinner
