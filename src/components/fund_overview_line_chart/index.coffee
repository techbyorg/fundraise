import {z} from 'zorium'
import _map from 'lodash/map'

import $chartLine from '../chart_line'
import config from '../../config'

if window?
  require './index.styl'

export default $fundOverviewlineChart = ({irsFund}) ->
  data = [{
    id: 'main'
    data: _map irsFund?.yearlyStats?.years, ({year, assets}) ->
      {
        x: year
        y: assets
      }
  }]

  z '.z-fund-overview-line-chart',
    z $chartLine, {data}
