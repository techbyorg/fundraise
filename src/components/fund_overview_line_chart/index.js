import { z } from 'zorium'
import * as _ from 'lodash-es'

import $chartLine from 'frontend-shared/components/chart_line'
import FormatService from 'frontend-shared/services/format'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundOverviewlineChart ({ metric, entity }) {
  // TODO: metric dropdown: assets, grant median, grant sum, grants made
  const data = [{
    id: 'main',
    data: _.filter(_.map(entity?.yearlyStats?.years, function (yearStats) {
      if (yearStats[metric] != null) {
        return {
          x: yearStats.year,
          y: yearStats[metric]
        }
      }
    }))
  }]

  return z('.z-fund-overview-line-chart', [
    z($chartLine, {
      data,
      chartOptions: {
        axisLeft: {
          format (value) {
            return FormatService.abbreviateDollar(Number(value), 2)
          }
        },
        yFormat (value) {
          return FormatService.abbreviateDollar(Number(value), 2)
        }
      }
    })
  ])
};
