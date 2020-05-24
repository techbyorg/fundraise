{z} = require 'zorium'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'
_reduce = require 'lodash/reduce'
_take = require 'lodash/take'

$chartPie = require '../chart_pie'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

LEGEND_COUNT = 5

module.exports = $fundOverviewNteePie = ({model, irsFund}) ->
  console.log 'colors', config.NTEE_MAJOR_COLORS
  # TODO: useMemo
  nteeMajors = _map irsFund?.fundedNteeMajors, ({count, percent}, nteeMajor) ->
    {count, percent, nteeMajor}
  nteeMajors = _orderBy nteeMajors, 'count', 'desc'
  pieNteeMajors = _reduce nteeMajors, (obj, {count, percent, nteeMajor}) ->
    if percent > 7
      obj[nteeMajor] = {count, percent, nteeMajor}
    else
      obj.rest ?= {count: 0, percent: 0, nteeMajor}
      obj.rest.count += count
      obj.rest.percent += percent
    obj
  , {}
  data = _map pieNteeMajors, ({count, percent, nteeMajor}) ->
    label = if nteeMajor is 'rest' \
            then model.l.get 'general.other' \
            else model.l.get "nteeMajor.#{nteeMajor}"

    color = if nteeMajor is 'rest' \
            then config.NTEE_MAJOR_COLORS['Z'] \
            else config.NTEE_MAJOR_COLORS[nteeMajor]
    {
      id: label
      label: label
      value: count
      percent: percent
      color: color
    }

  colors = _map data, 'color'

  z '.z-fund-overview-ntee-pie',
    z $chartPie, {data, colors}
    z '.legend',
      _map _take(nteeMajors, LEGEND_COUNT), ({count, percent, nteeMajor}) ->
        z '.legend-item',
          z '.color', {
            style:
              background: config.NTEE_MAJOR_COLORS[nteeMajor]
          }
          z '.info',
            z '.ntee', model.l.get "nteeMajor.#{nteeMajor}"
            # z '.dollars', FormatService.abbreviateDollar value
          z '.percent', "#{Math.round(percent)}%"
