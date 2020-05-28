z = require 'zorium'

$spinner = require 'frontend-shared/components/spinner'

config = require '../../config'

if window?
  require './index.styl'

module.exports = $homePage = ({requestsStream, serverData, entity}) ->
  z '.p-home',
    $spinner
