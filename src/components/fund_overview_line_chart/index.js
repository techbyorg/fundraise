// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
import { z } from 'zorium'
import * as _ from 'lodash-es'

import $chartLine from '../chart_line'

if (typeof window !== 'undefined' && window !== null) {
  require('./index.styl')
}

export default function $fundOverviewlineChart ({ metric, irsFund }) {
  // TODO: metric dropdown: assets, grant median, grant sum, grants made
  const data = [{
    id: 'main',
    data: _.filter(_.map(irsFund?.yearlyStats?.years, function (yearStats) {
      if (yearStats[metric] != null) {
        return {
          x: yearStats.year,
          y: yearStats[metric]
        }
      }
    }))
  }]

  return z('.z-fund-overview-line-chart',
    z($chartLine, { data }))
};
