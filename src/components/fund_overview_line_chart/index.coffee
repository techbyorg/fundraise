{z} = require 'zorium'
_map = require 'lodash/map'

$chartLine = require '../chart_line'
config = require '../../config'

if window?
  require './index.styl'

module.exports = $fundOverviewlineChart = ({model, irsFund}) ->
  data = [{
    id: 'main'
    data: _map irsFund?.yearlyStats?.years, ({year, assets}) ->
      {
        x: year
        y: assets
      }
  }]

  console.log 'data', data

  z '.z-fund-overview-line-chart',
    z $chartLine, {data}
