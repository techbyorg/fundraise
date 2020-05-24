{z} = require 'zorium'
_map = require 'lodash/map'

$chartUsMap = require '../chart_us_map'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $fundOverviewNteePie = ({model, irsFund}) ->
  data = _map irsFund?.contributionStats?.states, ({sum}, state) ->
    {
      id: state
      value: sum
    }

  console.log data

  z '.z-fund-overview-ntee-pie',
    z $chartUsMap, {data}
