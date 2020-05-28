{z, useContext} = require 'zorium'
_map = require 'lodash/map'
_orderBy = require 'lodash/orderBy'
_reduce = require 'lodash/reduce'
_take = require 'lodash/take'

FormatService = require 'frontend-shared/services/format'

$chartPie = require '../chart_pie'
context = require '../../context'
config = require '../../config'

if window?
  require './index.styl'

LEGEND_COUNT = 5

module.exports = $fundOverviewNteePie = ({irsFund}) ->
  {lang} = useContext context

  # TODO: useMemo?
  nteeMajors = _orderBy irsFund?.fundedNteeMajors, 'count', 'desc'
  pieNteeMajors = _reduce nteeMajors, (obj, {count, percent, key}) ->
    if percent > 7
      obj[key] = {count, percent, key}
    else
      obj.rest ?= {count: 0, percent: 0, key: 'rest'}
       # FIXME: find and add to 'rest'
      obj.rest.count += count
      obj.rest.percent += percent
    obj
  , {}
  data = _map pieNteeMajors, ({count, percent, key}) ->
    label = if key is 'rest' \
            then lang.get 'general.other' \
            else lang.get "nteeMajor.#{key}"

    color = if key is 'rest' \
            then config.NTEE_MAJOR_COLORS['Z'] \
            else config.NTEE_MAJOR_COLORS[key]
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
      _map _take(nteeMajors, LEGEND_COUNT), ({count, percent, key}) ->
        z '.legend-item',
          z '.color', {
            style:
              background: config.NTEE_MAJOR_COLORS[key]
          }
          z '.info',
            z '.ntee', lang.get "nteeMajor.#{key}"
            # z '.dollars', FormatService.abbreviateDollar value
          z '.percent', "#{Math.round(percent)}%"
