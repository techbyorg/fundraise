{z, useContext} = require 'zorium'
import _map from 'lodash/map'
import _orderBy from 'lodash/orderBy'
import _reduce from 'lodash/reduce'
import _take from 'lodash/take'

import FormatService from 'frontend-shared/services/format'

import $chartPie from '../chart_pie'
import context from '../../context'
import config from '../../config'

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
