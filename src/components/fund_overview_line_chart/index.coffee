import {z} from 'zorium'
import * as _ from 'lodash-es'

import $chartLine from '../chart_line'
import config from '../../config'

if window?
  require './index.styl'

export default $fundOverviewlineChart = ({irsFund}) ->
  data = [{
    id: 'main'
    data: _.map irsFund?.yearlyStats?.years, ({year, assets}) ->
      {
        x: year
        y: assets
      }
  }]

  z '.z-fund-overview-line-chart',
    z $chartLine, {data}
