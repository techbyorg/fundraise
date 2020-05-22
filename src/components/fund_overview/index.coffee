{z} = require 'zorium'

if window?
  require './index.styl'

module.exports = $fundOverview = ({model, router, irsFund}) ->
  z '.z-fund-overview',
    'overview'
