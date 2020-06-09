import {z} from 'zorium'

import $chartLine from '../chart_line'

if window?
  require './index.styl'

export default $fundOverviewlineChart = ({metric, irsFund}) ->
  # TODO: metric dropdown: assets, grant median, grant sum, grants made
  data = [{
    id: 'main'
    data: _.filter _.map irsFund?.yearlyStats?.years, (yearStats) ->
      if yearStats[metric]?
        {
          x: yearStats.year
          y: yearStats[metric]
        }
  }]

  z '.z-fund-overview-line-chart',
    z $chartLine, {data}
