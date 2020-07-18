import { z } from 'zorium'
import * as _ from 'lodash-es'
import $chartUsMap from 'frontend-shared/components/chart_us_map'
import FormatService from 'frontend-shared/services/format'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundOverviewNteePie ({ entity }) {
  const data = _.map(entity?.fundedStates, ({ key, sum }) => ({
    id: key,
    value: sum
  }))

  return z('.z-fund-overview-funding-map', [
    z($chartUsMap, {
      data,
      chartOptions: {
        valueFormat: (value) => {
          return FormatService.abbreviateDollar(Number(value))
        }
      }
    })
  ])
};
