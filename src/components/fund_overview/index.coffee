{z} = require 'zorium'

if window?
  require './index.styl'

module.exports = FundOverview = ({model, router, irsFund}) ->
  z '.z-fund-overview',
    'overview'
