{z} = require 'zorium'
_map = require 'lodash/map'

$chartUsMap = require '../chart_us_map'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $fundOverviewNteePie = ({irsFund}) ->
  data = _map irsFund?.fundedStates, ({key, sum}) ->
    {
      id: key
      value: sum
    }

  z '.z-fund-overview-funding-map',
    z $chartUsMap, {data}
