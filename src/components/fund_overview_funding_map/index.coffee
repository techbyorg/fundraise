{z} = require 'zorium'
import _map from 'lodash/map'

import $chartUsMap from '../chart_us_map'
import config from '../../config'

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
